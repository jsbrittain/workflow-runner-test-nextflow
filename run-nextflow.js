const Docker = require('dockerode');
const path = require('path');
const os = require('os');

const docker = new Docker(); // autodetects socket or named pipe

function toDockerPath(p) {
  if (os.platform() === 'win32') {
    const resolved = path.resolve(p);
    return '/' + resolved.replace(/\\/g, '/').replace(/^([A-Za-z]):/, (_, d) => d.toLowerCase());
  }
  return path.resolve(p);
}

async function run() {
  const localPath = process.cwd();
  const dockerPath = toDockerPath(localPath);

  console.log(`🛠️  Building Docker image "nextflow-conda"...`);
  await new Promise((resolve, reject) => {
    docker.buildImage(
      {
        context: localPath,
        src: ['Dockerfile'],
      },
      { t: 'nextflow-conda', platform: 'linux/amd64' },
      (err, output) => {
        if (err) return reject(err);
        output.pipe(process.stdout);
        output.on('end', resolve);
      }
    );
  });

  const binds = [
    '/tmp:/tmp',
    `${dockerPath}:${dockerPath}`,
    '/var/run/docker.sock:/var/run/docker.sock',
  ];

  console.log(`🚀 Running Nextflow in container from: ${dockerPath}`);

  const container = await docker.createContainer({
    Image: 'nextflow-conda',
    Tty: true,
    OpenStdin: true,
    AttachStdout: true,
    AttachStderr: true,
    HostConfig: {
      Binds: binds,
    },
    WorkingDir: dockerPath,
    Cmd: ['nextflow', 'run', 'main.nf'],
    Platform: 'linux/amd64',
  });

  const stream = await container.attach({
    stream: true,
    stdout: true,
    stderr: true,
    stdin: true,
  });

  stream.pipe(process.stdout);

  await container.start();

  // Handle SIGINT (Ctrl+C)
  process.on('SIGINT', async () => {
    console.log('\n🛑 Interrupted — stopping container...');
    try {
      await container.stop({ t: 5 });
      await container.remove();
    } catch (e) {
      console.error('Failed to stop/remove container:', e.message || e);
    }
    process.exit(1);
  });

  const result = await container.wait();

  stream.destroy(); // prevent process from hanging

  console.log('✅ Nextflow run complete');
  process.exit(result.StatusCode);
}

run().catch((err) => {
  console.error('❌ Error:', err.message || err);
  process.exit(1);
});
