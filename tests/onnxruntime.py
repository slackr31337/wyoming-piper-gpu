import onnxruntime as ort

# Check if CUDA execution provider is available
if 'CUDAExecutionProvider' in ort.get_available_providers():
    print("CUDA is available")

    # Get CUDA device information
    cuda_providers = [provider for provider in ort.get_available_providers() if provider.startswith('CUDA')]
    for provider in cuda_providers:
        print(f"Provider: {provider}")
        print(f"Device ID: {ort.get_device()}")

else:
    print("CUDA is not available")
