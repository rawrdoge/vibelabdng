use std::path::PathBuf;

use clap_mangen::Man;

use clap_complete::{
  Shell::{Bash, Elvish, Fish, PowerShell, Zsh},
  generate_to,
};

fn main() -> std::io::Result<()> {
  // `clap_mangen`/`clap_complete` render manpages and shell completions with
  // deep recursion. On Windows the default thread stack (1 MiB) is too small
  // for the full command tree and overflows (STATUS_STACK_OVERFLOW). Run the
  // generation on a thread with a large stack so the build always completes.
  let handle = std::thread::Builder::new()
    .stack_size(32 * 1024 * 1024)
    .spawn(|| -> std::io::Result<()> {
      build_manpages()?;
      build_completions()?;
      Ok(())
    })
    .expect("failed to spawn build-script thread");
  handle.join().expect("build-script thread panicked")
}

fn build_completions() -> std::io::Result<()> {
  let outdir = std::path::PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("completions");
  let mut cmd = dnglab_lib::app::create_app().name("dnglab");
  // Generate shell completions.
  for shell in [Bash, Elvish, Fish, PowerShell, Zsh] {
    generate_to(shell, &mut cmd, "dnglab", &outdir).map_err(|e| std::io::Error::new(std::io::ErrorKind::Other, format!("completions build failed: {e}")))?;
  }
  Ok(())
}

fn build_manpages() -> std::io::Result<()> {
  let outdir = std::path::PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("manpages");
  let name = "dnglab";
  let cmd = dnglab_lib::app::create_app().name("dnglab");
  let man = clap_mangen::Man::new(cmd.clone());
  let mut buffer: Vec<u8> = Default::default();
  man.render(&mut buffer)?;

  std::fs::write(outdir.join("dnglab.1"), buffer)?;

  for subcommand in cmd.get_subcommands() {
    let subcommand_name = subcommand.get_name();
    let subcommand_name = format!("{name}-{subcommand_name}");
    let mut buffer: Vec<u8> = Default::default();
    let man = Man::new(subcommand.clone().name(&subcommand_name));
    man.render(&mut buffer)?;
    std::fs::write(PathBuf::from(&outdir).join(format!("{}{}", &subcommand_name, ".1")), buffer)?;
  }
  Ok(())
}
