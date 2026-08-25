module VkFFTOpenCL

using OpenCL
using Reexport
@reexport using VkFFT

"""
    __init__()

Warns when VkFFT's OpenCL extension did not activate, which leaves this package doing nothing.

The check dispatches on OpenCL.CLArray so it also catches any extension
loaded against a different version of VkFFT's backend interface. It remains a
warning. A machine without an OpenCL runtime should still be able to precompile
a project that depends on this package.

# Returns
- `nothing`
"""
function __init__()
    active = try
        VkFFT._backend(OpenCL.CLArray{ComplexF32, 1, OpenCL.cl.Buffer}) === Val(:opencl)
    catch
        false
    end
    active || @warn "VkFFT's OpenCL extension did not activate, so VkFFT.plan_fft cannot take a CLArray. Check that OpenCL and VkFFT both precompiled properly." maxlog=1

    return nothing
end

end # module
