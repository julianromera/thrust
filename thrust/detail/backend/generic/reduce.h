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


#pragma once

#include <thrust/detail/config.h>
#include <thrust/detail/backend/generic/tag.h>
#include <thrust/iterator/iterator_traits.h>

namespace thrust
{
namespace detail
{
namespace backend
{
namespace generic
{

template<typename InputIterator>
  typename thrust::iterator_traits<InputIterator>::value_type
    reduce(tag, InputIterator first, InputIterator last);

template<typename InputIterator, typename T>
  T reduce(tag, InputIterator first, InputIterator last, T init);

// the fully general form of reduce has no implementation -- it is an error to call it
template<typename InputIterator,
         typename T,
         typename BinaryFunction>
  T reduce(tag, InputIterator first, InputIterator last, T init, BinaryFunction binary_op);

template<typename RandomAccessIterator,
         typename SizeType,
         typename OutputType,
         typename BinaryFunction>
  OutputType reduce_n(RandomAccessIterator first,
                      SizeType n,
                      OutputType init,
                      BinaryFunction binary_op);

} // end namespace generic
} // end namespace backend
} // end namespace detail
} // end namespace thrust

#include <thrust/detail/backend/generic/reduce.inl>

