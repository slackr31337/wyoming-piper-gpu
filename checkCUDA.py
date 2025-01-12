"""
    From https://github.com/rhasspy/piper/issues/24
"""

import torch
import os

def print_cuda_details():

    if torch.cuda.is_available():
        # GPU device details
        device_id = torch.cuda.current_device()
        device_name = torch.cuda.get_device_name(device_id)
        total_memory = torch.cuda.get_device_properties(device_id).total_memory / (1024**3)  # GB
        memory_allocated = torch.cuda.memory_allocated(device_id) / (1024**3)  # GB
        memory_cached = torch.cuda.memory_reserved(device_id) / (1024**3)  # GB
        multiprocessors = torch.cuda.get_device_properties(device_id).multi_processor_count
        
        # CUDA and PyTorch versions
        cuda_version = torch.version.cuda
        pytorch_version = torch.__version__

        # Device properties
        device_properties = torch.cuda.get_device_properties(device_id)
        compute_capability = device_properties.major, device_properties.minor
        
        # Display the details with improved formatting
        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        print(f"")
        print("Checking CUDA information within the python environment...")
        print(f"")

        print("###########################################################")
        print(f"CUDA Available:         TRUE")
        print(f"Using GPU:              {device_name}")
        print("###########################################################")
        print(f"")

        print(f"CUDA Version:           {cuda_version}")
        print(f"PyTorch Version:        {pytorch_version}")
        print(f"Device ID:              {device_id}")
        print(f"Total Memory:           {total_memory:.2f} GB")
        print(f"Memory Allocated:       {memory_allocated:.2f} GB")
        print(f"Memory Cached:          {memory_cached:.2f} GB")
        print(f"Multiprocessors:        {multiprocessors}")
        print(f"Compute Capability:     {compute_capability[0]}.{compute_capability[1]}")
        print(f"")

        # Device Name
        print(f"CUDA Device Name:       {torch.cuda.get_device_name(device_id)}")
        print(f"")

        # CUDA Path (from environment variables)
        cuda_path = os.getenv('CUDA_PATH', 'Not set')
        print(f"CUDA Path:              {cuda_path}")
        
        # CUDA Toolkit Directory (check via environment variable if available)
        cuda_toolkit_dir = os.getenv('CUDA_HOME', 'Not set')
        print(f"CUDA Toolkit Dir:       {cuda_toolkit_dir}")
        
        # Environment Variables
        print(f"\n")
        print("=================================================")
        print("--- Below are OS SYSTEM Environment Variables ---")
        print(" not just whats available within the python VENV")
        print("=================================================")
        print(f"")

        print(f"{'CUDA_HOME:':<25} {os.environ.get('CUDA_HOME', 'Not set')}")
        print(f"")

        print(f"{'CUDA_VISIBLE_DEVICES:':<25} {os.environ.get('CUDA_VISIBLE_DEVICES', 'Not set')}")
        print(f"")

        print(f"{'LD_LIBRARY_PATH:':<25} {os.environ.get('LD_LIBRARY_PATH', 'Not set')}")
        print(f"")

        print(f"{'PATH:':<25} {os.environ.get('PATH', 'Not set')}")
        print(f"")

        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    else:
        print("##############################################################")
        print("CUDA is NOT available! You may need to reinstall Pytorch/Torch")
        print("Falling back to using CPU.")
        print("##############################################################")
        print(f"")

        # Provide details for CPU-based configurations
        print(f"PyTorch Version:        {torch.__version__}")
        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

# Call the function to print details
print_cuda_details()