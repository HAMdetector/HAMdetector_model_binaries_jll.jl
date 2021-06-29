# Use baremodule to shave off a few KB from the serialized `.ji` file
baremodule HAMdetector_model_binaries_jll
using Base
using Base: UUID
import JLLWrappers

JLLWrappers.@generate_main_file_header("HAMdetector_model_binaries")
JLLWrappers.@generate_main_file("HAMdetector_model_binaries", UUID("42556b90-06fa-5035-9d39-4d53cd3bfd44"))
end  # module HAMdetector_model_binaries_jll
