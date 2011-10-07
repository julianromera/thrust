/*
 *  Copyright 2008-2011 NVIDIA Corporation
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */


#include <thrust/iterator/iterator_traits.h>

#include <thrust/detail/minmax.h>

#include <thrust/detail/backend/decompose.h>

#include <thrust/detail/backend/cuda/extern_shared_ptr.h>
#include <thrust/detail/backend/cuda/block/reduce.h>
#include <thrust/detail/backend/cuda/detail/launch_closure.h>
#include <thrust/detail/backend/cuda/detail/launch_calculator.h>

namespace thrust
{
namespace detail
{
namespace backend
{
namespace cuda
{

template <typename InputIterator,
          typename OutputIterator,
          typename BinaryFunction,
          typename Decomposition>
struct commutative_reduce_intervals_closure : public thrust::detail::backend::cuda::detail::cuda_closure<>
{
  InputIterator  input;
  OutputIterator output;
  BinaryFunction binary_op;
  Decomposition  decomposition;
  unsigned int shared_array_size;

  commutative_reduce_intervals_closure(InputIterator input, OutputIterator output, BinaryFunction binary_op, Decomposition decomposition, unsigned int shared_array_size)
    : input(input), output(output), binary_op(binary_op), decomposition(decomposition), shared_array_size(shared_array_size) {}

  __device__ 
  void operator()(void)
  {
    typedef typename thrust::iterator_value<OutputIterator>::type OutputType;
    thrust::detail::backend::cuda::extern_shared_ptr<OutputType>  shared_array;

    typedef typename Decomposition::index_type index_type;
   
    // this block processes results in [range.begin(), range.end())
    thrust::detail::backend::index_range<index_type> range = decomposition[block_index()];

    index_type i = range.begin() + thread_index();
      
    input += i;

    if (range.size() < block_dimension())
    {
      // compute reduction with the first shared_array_size threads
      if (thread_index() < thrust::min<index_type>(shared_array_size,range.size()))
      {
        OutputType sum = dereference(input);

        i     += shared_array_size;
        input += shared_array_size;

        while (i < range.end())
        {
          OutputType val = dereference(input);

          sum = binary_op(sum, val);

          i      += shared_array_size;
          input  += shared_array_size;
        }

        shared_array[thread_index()] = sum;  
      }
    }
    else
    {
      // compute reduction with all blockDim.x threads
      OutputType sum = dereference(input);

      i     += block_dimension();
      input += block_dimension();

      while (i < range.end())
      {
        OutputType val = dereference(input);

        sum = binary_op(sum, val);

        i      += block_dimension();
        input  += block_dimension();
      }

      // write first shared_array_size values into shared memory
      if (thread_index() < shared_array_size)
        shared_array[thread_index()] = sum;  

      // accumulate remaining values (if any) to shared memory in stages
      if (block_dimension() > shared_array_size)
      {
        unsigned int lb = shared_array_size;
        unsigned int ub = shared_array_size + lb;
        
        while (lb < block_dimension())
        {
          barrier();

          if (lb <= thread_index() && thread_index() < ub)
          {
            OutputType tmp = shared_array[thread_index() - lb];
            shared_array[thread_index() - lb] = binary_op(tmp, sum);
          }

          lb += shared_array_size;
          ub += shared_array_size;
        }
      }
    }
  
    barrier();

// TODO remove guard
// CUDA built-in variables require nvcc
#if THRUST_DEVICE_COMPILER == THRUST_DEVICE_COMPILER_NVCC
    thrust::detail::backend::cuda::block::reduce_n(shared_array, thrust::min<index_type>(range.size(), shared_array_size), binary_op);
#endif // THRUST_DEVICE_COMPILER_NVCC
  
    if (thread_index() == 0)
    {
      output += block_index();
      dereference(output) = shared_array[0];
    }
  }
};

__THRUST_DISABLE_MSVC_POSSIBLE_LOSS_OF_DATA_WARNING_BEGIN

template <typename InputIterator,
          typename OutputIterator,
          typename BinaryFunction,
          typename Decomposition>
void reduce_intervals(InputIterator input,
                      OutputIterator output,
                      BinaryFunction binary_op,
                      Decomposition decomp)
{
  // we're attempting to launch a kernel, assert we're compiling with nvcc
  // ========================================================================
  // X Note to the user: If you've found this line due to a compiler error, X
  // X you need to compile your code using nvcc, rather than g++ or cl.exe  X
  // ========================================================================
  THRUST_STATIC_ASSERT( (depend_on_instantiation<InputIterator, THRUST_DEVICE_COMPILER == THRUST_DEVICE_COMPILER_NVCC>::value) );

  if (decomp.size() == 0)
    return;
  
  // TODO if (decomp.size() > deviceProperties.maxGridSize[0]) throw cuda exception (or handle general case)

  typedef commutative_reduce_intervals_closure<InputIterator,OutputIterator,BinaryFunction,Decomposition> Closure;
  typedef typename thrust::iterator_value<OutputIterator>::type OutputType;
  
  thrust::detail::backend::cuda::detail::launch_calculator<Closure> calculator;

  thrust::tuple<size_t,size_t,size_t> config = calculator.with_variable_block_size_available_smem();

  //size_t max_blocks = thrust::get<0>(config);
  size_t block_size = thrust::get<1>(config);
  size_t max_memory = thrust::get<2>(config);

  // determine shared array size
  size_t shared_array_size  = thrust::min(max_memory / sizeof(OutputType), block_size);
  size_t shared_array_bytes = sizeof(OutputType) * shared_array_size;
  
  // TODO if (shared_array_size < 1) throw cuda exception "insufficient shared memory"

  Closure closure(input, output, binary_op, decomp, shared_array_size);

  //std::cout << "Launching " << decomp.size() << " blocks of kernel with " << block_size << " threads and " << shared_array_bytes << " shared memory per block " << std::endl;
  
  thrust::detail::backend::cuda::detail::launch_closure(closure, decomp.size(), block_size, shared_array_bytes);
}

__THRUST_DISABLE_MSVC_POSSIBLE_LOSS_OF_DATA_WARNING_END

} // end namespace cuda
} // end namespace backend
} // end namespace detail
} // end namespace thrust

