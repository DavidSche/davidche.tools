# 在 windows 环境构建源码

Nowadays best way looks to be:

- Install Go
- Include these extra binaries
- moby/Dockerfile.windows

Lines 229 to 236 in 34b8670

 Write-Host INFO: Downloading compiler 1 of 3...; ` 
 Download-File https://raw.githubusercontent.com/moby/docker-tdmgcc/master/gcc.zip C:\gcc.zip; ` 
 ` 
 Write-Host INFO: Downloading compiler 2 of 3...; ` 
 Download-File https://raw.githubusercontent.com/moby/docker-tdmgcc/master/runtime.zip C:\runtime.zip; ` 
 ` 
 Write-Host INFO: Downloading compiler 3 of 3...; ` 
 Download-File https://raw.githubusercontent.com/moby/docker-tdmgcc/master/binutils.zip C:\binutils.zip; ` 
(I copied them to same folders with Go like it is done in Dockerfile.Windows)

- Configure environment variables GOBIN=C:\Program Files\Go\bin and GO111MODULE=off
- Build with PowerShell command:
  
```
.\hack\make.ps1 -Daemon -Noisy
```

That way you don't need Docker for build (which makes easier to play with test versions) and after first build it is very rebuild when debugging code.
