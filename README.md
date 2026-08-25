# VkFFTOpenCL.jl

Runs [VkFFT](https://github.com/DTolm/VkFFT) on `CLArray`s by loading VkFFT.jl
with its OpenCL backend. This package simply activates VkFFT's OpenCL extension,
and re-exports VkFFT.

```julia
using VkFFTOpenCL, OpenCL, LinearAlgebra

x = CLArray{ComplexF32}(undef, 1024, 64)
copyto!(x, rand(ComplexF32, 1024, 64))

p = VkFFT.plan_fft(x, 1) # transform along dimension 1, batch over dimension 2
y = p * x                # or mul!(y, p, x)
x2 = inv(p) * y          # normalized inverse, 1/N applied inside the kernel
```

Everything else (including the entry points, the plans, and the real transforms)
is documented in [VkFFT.jl](https://www.github.com/PaulVirally/VkFFT.jl).

## Setup

VkFFT drives `clSetKernelArg` with a `cl_mem`, so OpenCL.jl has to hand out buffer-backed
arrays rather than its default unified-memory ones:

```julia
using Preferences, OpenCL
set_preferences!(OpenCL, "default_memory_backend" => "buffer")
```

VkFFT.jl calls [a small C wrapper](https://www.github.com/PaulVirally/libvkfft)
around VkFFT, and until that wrapper ships as a JLL you need to build it
yourself and point the package to the resulting share library:

```julia
using Preferences, VkFFT
set_preferences!(VkFFT, "libvkfft_path" => "/path/to/libvkfft.so")
```

Build it with `-DVKFFT_BACKEND=3` from the `libvkfft` sources, linked against an
**ICD loader** rather than against a vendor framework directly. OpenCL.jl
reaches devices through the ICD loader, and a wrapper that bypasses it reports
`VKFFT_ERROR_FAILED_TO_GET_ATTRIBUTE` on every plan.

TODO: once `VkFFT_OpenCL_jll` is registered it becomes a dependency for this
package, ships the wrapper as an artifact, and the preference above becomes an
override for people who want their own build.

## No GPU needed

OpenCL is the backend that runs on a CPU. Add `pocl_jll` and the whole stack works with no
graphics hardware at all, which is how VkFFT.jl's own test suite runs.

## Status

Complex-to-complex and real-to-complex transforms, `ComplexF32`, `ComplexF64` and their
`Float32`/`Float64` reals. No DCT/DST, no fused convolution, no zero-padding, no half or quad
precision, no autotuner and no kernel binary cache yet.

TODO: Link to VkDCT if we don't end up doing this ourselves.
