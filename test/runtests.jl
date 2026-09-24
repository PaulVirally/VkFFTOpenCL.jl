using Test
using pocl_jll # has to load before OpenCL.jl first lists its platforms
using VkFFTOpenCL
using VkFFTOpenCL.OpenCL: CLArray, cl

# VkFFT takes cl_mem handles, so arrays have to be buffer backed
task_local_storage(:CLMemoryBackend, cl.BufferBackend())

@testset "VkFFTOpenCL" begin
    delta = zeros(ComplexF32, 256, 4)
    delta[1, :] .= 1
    x = CLArray(delta)
    p = VkFFT.plan_fft(x, 1)
    @test Array(p * x) ≈ ones(ComplexF32, 256, 4)
    @test Array(inv(p) * (p * x)) ≈ delta

    r = CLArray(ones(Float32, 256))
    @test Array(VkFFT.plan_rfft(r) * r) ≈ [256; zeros(128)]
end
