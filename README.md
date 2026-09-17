# VkFFTOpenCL.jl

Runs [VkFFT](https://github.com/DTolm/VkFFT) on `CLArray`s. The package depends
on OpenCL.jl and VkFFT.jl, which is what activates VkFFT.jl's OpenCL extension.
It re-exports VkFFT.jl.

## Setup

```julia
Pkg.add("VkFFTOpenCL")
```

That pulls in VkFFT_OpenCL_jll, which ships the prebuilt wrapper. To build the
wrapper yourself, see the [developer
docs](https://paulvirally.github.io/VkFFT.jl/stable/building/).

VkFFT drives `clSetKernelArg` with a `cl_mem`, so OpenCL.jl has to hand out
buffer-backed arrays rather than its default unified-memory ones. You must set
this preference yourself:

```julia
using Preferences, OpenCL
set_preferences!(OpenCL, "default_memory_backend" => "buffer")
```

## Use

```julia
using VkFFTOpenCL, OpenCL, LinearAlgebra

x = CLArray{ComplexF32}(undef, 256, 64)
copyto!(x, rand(ComplexF32, 256, 64))

p = VkFFT.plan_fft(x, 1) # transform along dimension 1, batch over dimension 2
y = p * x                # or mul!(y, p, x)
x2 = inv(p) * y          # normalized inverse, 1/N applied inside the kernel
```

## Devices

OpenCL is the only backend for VkFFT that can run on CPU. To use VkFFT on CPU,
you must use `pocl_jll`:

```julia
using VkFFTOpenCL, OpenCL
using pocl_jll

# ... do some ffts
```

`Float16` and `ComplexF16` are refused on a device whose extension list does not
report `cl_khr_fp16`, with a message naming the device, because VkFFT otherwise
emits half2 arithmetic the driver will not compile. pocl is one such device.

## Documentation

The entry points, the transform families, tuning and the per-backend capability
matrix can be found in the [VkFFT.jl
documentation](https://paulvirally.github.io/VkFFT.jl/stable/).
