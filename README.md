# VkFFTOpenCL.jl

Runs [VkFFT](https://github.com/DTolm/VkFFT) on `CLArray`s. The package depends
on OpenCL.jl and VkFFT.jl, which is what activates VkFFT.jl's OpenCL extension.
It re-exports VkFFT.jl.

## Setup

TODO(jll): install instructions pending VkFFT_OpenCL_jll registration. Until
then, the libvkfft_path preference is the only way in.

`Pkg.add("VkFFTOpenCL")` installs the Julia side.

VkFFT drives `clSetKernelArg` with a `cl_mem`, so OpenCL.jl has to hand out
buffer-backed arrays rather than its default unified-memory ones. Nothing plans
until this is set:

```julia
using Preferences, OpenCL
set_preferences!(OpenCL, "default_memory_backend" => "buffer")
```

VkFFT.jl also calls [a small C wrapper](https://github.com/PaulVirally/libvkfft)
around VkFFT, and there is no JLL for it yet, so build it yourself and point the
package at it:

```julia
using Preferences, VkFFT
set_preferences!(VkFFT, "libvkfft_path" => "/path/to/libvkfft.so")
```

Build it with `-DVKFFT_BACKEND=3`, linked against an ICD loader rather than
against a vendor framework directly. OpenCL.jl reaches devices through the
loader, and a wrapper that bypasses it reports
`VKFFT_ERROR_FAILED_TO_GET_ATTRIBUTE` on every plan. On macOS that means adding
`-DVKFFT_OPENCL_FORCE_ICD_LOADER=ON`.

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

OpenCL is the backend that runs on a CPU. Add `pocl_jll` and the whole stack
works with no graphics hardware, which is how VkFFT.jl's test suite runs.

`Float16` and `ComplexF16` are refused on a device whose extension list does not
report `cl_khr_fp16`, with a message naming the device, because VkFFT otherwise
emits half2 arithmetic the driver will not compile. pocl is one such device.

## Documentation

The entry points, the transform families, tuning and the per-backend capability
matrix are in the
[VkFFT.jl documentation](https://paulvirally.github.io/VkFFT.jl/stable/).
