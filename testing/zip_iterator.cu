#include <thrusttest/unittest.h>
#include <thrust/iterator/zip_iterator.h>
#include <thrust/tuple.h>
#include <thrust/host_vector.h>
#include <thrust/iterator/counting_iterator.h>
#include <thrust/sequence.h>
#include <thrust/copy.h>
#include <thrust/transform.h>
#include <thrust/reduce.h>
#include <thrust/scan.h>
#include <thrust/sort.h>
#include <thrust/detail/type_traits.h>
#include <typeinfo>

using namespace thrusttest;
using namespace thrust;

template<typename T>
  struct TestZipIteratorManipulation
{
  template<typename Vector>
  void test(void)
  {
    Vector v0(4);
    Vector v1(4);
    Vector v2(4);

    // initialize input
    sequence(v0.begin(), v0.end());
    sequence(v1.begin(), v1.end());
    sequence(v2.begin(), v2.end());

    typedef tuple<typename Vector::iterator, typename Vector::iterator> IteratorTuple;

    IteratorTuple t = make_tuple(v0.begin(), v1.begin());

    typedef experimental::zip_iterator<IteratorTuple> ZipIterator;

    // test construction
    ZipIterator iter0 = experimental::make_zip_iterator(t);

    ASSERT_EQUAL_QUIET(v0.begin(), get<0>(iter0.get_iterator_tuple()));
    ASSERT_EQUAL_QUIET(v1.begin(), get<1>(iter0.get_iterator_tuple()));

    // test dereference
    ASSERT_EQUAL(*v0.begin(), get<0>(*iter0));
    ASSERT_EQUAL(*v1.begin(), get<1>(*iter0));

    // test equality
    ZipIterator iter1 = iter0;
    ZipIterator iter2 = experimental::make_zip_iterator(make_tuple(v0.begin(), v2.begin()));
    ASSERT_EQUAL(true,  iter0 == iter1);
    ASSERT_EQUAL(false, iter0 == iter2);

    // test inequality
    ASSERT_EQUAL(false, iter0 != iter1);
    ASSERT_EQUAL(true,  iter0 != iter2);

    // test advance
    ZipIterator iter3 = iter0 + 1;
    ASSERT_EQUAL_QUIET(v0.begin() + 1, get<0>(iter3.get_iterator_tuple()));
    ASSERT_EQUAL_QUIET(v1.begin() + 1, get<1>(iter3.get_iterator_tuple()));

    // test pre-increment
    ++iter3;
    ASSERT_EQUAL_QUIET(v0.begin() + 2, get<0>(iter3.get_iterator_tuple()));
    ASSERT_EQUAL_QUIET(v1.begin() + 2, get<1>(iter3.get_iterator_tuple()));

    // test post-increment
    iter3++;
    ASSERT_EQUAL_QUIET(v0.begin() + 3, get<0>(iter3.get_iterator_tuple()));
    ASSERT_EQUAL_QUIET(v1.begin() + 3, get<1>(iter3.get_iterator_tuple()));

    // test pre-decrement
    --iter3;
    ASSERT_EQUAL_QUIET(v0.begin() + 2, get<0>(iter3.get_iterator_tuple()));
    ASSERT_EQUAL_QUIET(v1.begin() + 2, get<1>(iter3.get_iterator_tuple()));

    // test post-decrement
    iter3--;
    ASSERT_EQUAL_QUIET(v0.begin() + 1, get<0>(iter3.get_iterator_tuple()));
    ASSERT_EQUAL_QUIET(v1.begin() + 1, get<1>(iter3.get_iterator_tuple()));

    // test difference
    ASSERT_EQUAL( 1, iter3 - iter0);
    ASSERT_EQUAL(-1, iter0 - iter3);
  }

  void operator()(void)
  {
    test<   thrust::host_vector<T> >();
    test< thrust::device_vector<T> >();
  }
};
SimpleUnitTest<TestZipIteratorManipulation, type_list<int> > TestZipIteratorManipulationInstance;

template <typename T>
  struct TestZipIteratorReference
{
  void operator()(void)
  {
    // test host types
    typedef typename host_vector<T>::iterator          Iterator1;
    typedef typename host_vector<T>::const_iterator    Iterator2;
    typedef tuple<Iterator1,Iterator2>                 IteratorTuple1;
    typedef experimental::zip_iterator<IteratorTuple1> ZipIterator1;

    typedef typename experimental::iterator_reference<ZipIterator1>::type zip_iterator_reference_type1;

    host_vector<T> h_variable(1);

    typedef tuple<T&,const T&> reference_type1;

    reference_type1               ref1(*h_variable.begin(),*h_variable.cbegin());
    zip_iterator_reference_type1 test1(*h_variable.begin(),*h_variable.cbegin());

    ASSERT_EQUAL_QUIET(ref1, test1);
    ASSERT_EQUAL( get<0>(ref1),  get<0>(test1));
    ASSERT_EQUAL( get<1>(ref1),  get<1>(test1));


    // test device types
    typedef typename device_vector<T>::iterator        Iterator3;
    typedef typename device_vector<T>::const_iterator  Iterator4;
    typedef tuple<Iterator3,Iterator4>                 IteratorTuple2;
    typedef experimental::zip_iterator<IteratorTuple2> ZipIterator2;

    typedef typename experimental::iterator_reference<ZipIterator2>::type zip_iterator_reference_type2;

    device_vector<T> d_variable(1);

    typedef tuple< device_reference<T>, device_reference<const T> > reference_type2;

    reference_type2               ref2(*d_variable.begin(),*d_variable.cbegin());
    zip_iterator_reference_type2 test2(*d_variable.begin(),*d_variable.cbegin());

    ASSERT_EQUAL_QUIET(ref2, test2);
    ASSERT_EQUAL( get<0>(ref2),  get<0>(test2));
    ASSERT_EQUAL( get<1>(ref2),  get<1>(test2));
  } // end operator()()
};
SimpleUnitTest<TestZipIteratorReference, NumericTypes> TestZipIteratorReferenceInstance;


template <typename T>
  struct TestZipIteratorTraversal
{
  void operator()(void)
  {
    // test host types
    typedef typename host_vector<T>::iterator          Iterator1;
    typedef typename host_vector<T>::const_iterator    Iterator2;
    typedef tuple<Iterator1,Iterator2>                 IteratorTuple1;
    typedef experimental::zip_iterator<IteratorTuple1> ZipIterator1;

    typedef typename experimental::iterator_traversal<ZipIterator1>::type zip_iterator_traversal_type1;

    //ASSERT_EQUAL(true, (detail::is_convertible<zip_iterator_traversal_type1, experimental::random_access_traversal_tag>::value) );


    // test device types
    typedef typename device_vector<T>::iterator        Iterator3;
    typedef typename device_vector<T>::const_iterator  Iterator4;
    typedef tuple<Iterator3,Iterator4>                 IteratorTuple2;
    typedef experimental::zip_iterator<IteratorTuple2> ZipIterator2;

    typedef typename experimental::iterator_traversal<ZipIterator2>::type zip_iterator_traversal_type2;

    //ASSERT_EQUAL(true, (detail::is_convertible<zip_iterator_traversal_type2, thrust::random_access_traversal_tag>::value) );
  } // end operator()()
};
SimpleUnitTest<TestZipIteratorTraversal, NumericTypes> TestZipIteratorTraversalInstance;


template <typename T>
  struct TestZipIteratorSpace
{
  void operator()(void)
  {
    // XXX these assertions complain about undefined references to integral_constant<...>::value

    // test host types
    typedef typename host_vector<T>::iterator          Iterator1;
    typedef typename host_vector<T>::const_iterator    Iterator2;
    typedef tuple<Iterator1,Iterator2>                 IteratorTuple1;
    typedef experimental::zip_iterator<IteratorTuple1> ZipIterator1;

    typedef typename experimental::iterator_space<ZipIterator1>::type zip_iterator_space_type1;

    //ASSERT_EQUAL(true, (detail::is_same<zip_iterator_space_type1, experimental::space::host>::value) );


    // test device types
    typedef typename device_vector<T>::iterator        Iterator3;
    typedef typename device_vector<T>::const_iterator  Iterator4;
    typedef tuple<Iterator3,Iterator4>                 IteratorTuple2;
    typedef experimental::zip_iterator<IteratorTuple1> ZipIterator2;

    typedef typename experimental::iterator_space<ZipIterator2>::type zip_iterator_space_type2;

    //ASSERT_EQUAL(true, (detail::is_convertible<zip_iterator_space_type2, experimental::space::device>::value) );


    // test any
    typedef experimental::counting_iterator<T>         Iterator5;
    typedef experimental::counting_iterator<const T>   Iterator6;
    typedef tuple<Iterator5, Iterator6>                IteratorTuple3;
    typedef experimental::zip_iterator<IteratorTuple3> ZipIterator3;

    typedef typename experimental::iterator_space<ZipIterator3>::type zip_iterator_space_type3;

    //ASSERT_EQUAL(true, (detail::is_convertible<zip_iterator_space_type3, thrust::experimental::space::any>::value) );

    
    // test host/any
    typedef tuple<Iterator1, Iterator5>                IteratorTuple4;
    typedef experimental::zip_iterator<IteratorTuple4> ZipIterator4;

    typedef typename experimental::iterator_space<ZipIterator4>::type zip_iterator_space_type4;

    //ASSERT_EQUAL(true, (detail::is_convertible<zip_iterator_space_type4, thrust::experimental::space::host>::value) );


    // test any/host
    typedef tuple<Iterator5, Iterator1>                IteratorTuple5;
    typedef experimental::zip_iterator<IteratorTuple5> ZipIterator5;

    typedef typename experimental::iterator_space<ZipIterator5>::type zip_iterator_space_type5;

    //ASSERT_EQUAL(true, (detail::is_convertible<zip_iterator_space_type5, thrust::experimental::space::host>::value) );


    // test device/any
    typedef tuple<Iterator3, Iterator5>                IteratorTuple6;
    typedef experimental::zip_iterator<IteratorTuple6> ZipIterator6;

    typedef typename experimental::iterator_space<ZipIterator6>::type zip_iterator_space_type6;

    //ASSERT_EQUAL(true, (detail::is_convertible<zip_iterator_space_type6, thrust::experimental::space::device>::value) );


    // test any/device
    typedef tuple<Iterator5, Iterator3>                IteratorTuple7;
    typedef experimental::zip_iterator<IteratorTuple7> ZipIterator7;

    typedef typename experimental::iterator_space<ZipIterator7>::type zip_iterator_space_type7;

    //ASSERT_EQUAL(true, (detail::is_convertible<zip_iterator_space_type7, thrust::experimental::space::device>::value) );
  } // end operator()()
};
SimpleUnitTest<TestZipIteratorSpace, NumericTypes> TestZipIteratorSpaceInstance;


template <typename Vector>
void TestZipIteratorCopy(void)
{
  Vector input0(4),  input1(4);
  Vector output0(4), output1(4);

  // initialize input
  sequence(input0.begin(), input0.end(),  0);
  sequence(input1.begin(), input1.end(), 13);

  thrust::copy( make_zip_iterator(make_tuple(input0.begin(),  input1.begin())),
                make_zip_iterator(make_tuple(input0.end(),    input1.end())),
                make_zip_iterator(make_tuple(output0.begin(), output1.begin())));

  ASSERT_EQUAL(input0, output0);
  ASSERT_EQUAL(input1, output1);
}
DECLARE_VECTOR_UNITTEST(TestZipIteratorCopy);


struct SumTwoTuple
{
  template<typename Tuple>
  __host__ __device__
  typename detail::remove_reference<typename tuple_element<0,Tuple>::type>::type
    operator()(Tuple x) const
  {
    return get<0>(x) + get<1>(x);
  }
}; // end SumTwoTuple

struct SumThreeTuple
{
  template<typename Tuple>
  __host__ __device__
  typename detail::remove_reference<typename tuple_element<0,Tuple>::type>::type
    operator()(Tuple x) const
  {
    return get<0>(x) + get<1>(x) + get<2>(x);
  }
}; // end SumThreeTuple


template <typename T>
struct TestZipIteratorTransform
{
  void operator()(const size_t n)
  {
    thrust::host_vector<T> h_data0 = thrusttest::random_samples<T>(n);
    thrust::host_vector<T> h_data1 = thrusttest::random_samples<T>(n);
    thrust::host_vector<T> h_data2 = thrusttest::random_samples<T>(n);

    thrust::device_vector<T> d_data0 = h_data0;
    thrust::device_vector<T> d_data1 = h_data1;
    thrust::device_vector<T> d_data2 = h_data2;

    thrust::host_vector<T>   h_result(n);
    thrust::device_vector<T> d_result(n);

    // Tuples with 2 elements
    thrust::transform( make_zip_iterator(make_tuple(h_data0.begin(), h_data1.begin())),
                       make_zip_iterator(make_tuple(h_data0.end(),   h_data1.end())),
                       h_result.begin(),
                       SumTwoTuple());
    thrust::transform( make_zip_iterator(make_tuple(d_data0.begin(), d_data1.begin())),
                       make_zip_iterator(make_tuple(d_data0.end(),   d_data1.end())),
                       d_result.begin(),
                       SumTwoTuple());
    ASSERT_EQUAL(h_result, d_result);
    
    
    // Tuples with 3 elements
    thrust::transform( make_zip_iterator(make_tuple(h_data0.begin(), h_data1.begin(), h_data2.begin())),
                       make_zip_iterator(make_tuple(h_data0.end(),   h_data1.end(),   h_data2.end())),
                       h_result.begin(),
                       SumThreeTuple());
    thrust::transform( make_zip_iterator(make_tuple(d_data0.begin(), d_data1.begin(), d_data2.begin())),
                       make_zip_iterator(make_tuple(d_data0.end(),   d_data1.end(),   d_data2.end())),
                       d_result.begin(),
                       SumThreeTuple());
    ASSERT_EQUAL(h_result, d_result);
  }
};
VariableUnitTest<TestZipIteratorTransform, ThirtyTwoBitTypes> TestZipIteratorTransformInstance;


template<typename Tuple>
struct TuplePlus
{
  __host__ __device__
  Tuple operator()(Tuple x, Tuple y) const
  {
    return make_tuple(get<0>(x) + get<0>(y),
                      get<1>(x) + get<1>(y));
  }
}; // end SumTuple


template <typename T>
struct TestZipIteratorReduce
{
  void operator()(const size_t n)
  {
    thrust::host_vector<T> h_data0 = thrusttest::random_samples<T>(n);
    thrust::host_vector<T> h_data1 = thrusttest::random_samples<T>(n);

    thrust::device_vector<T> d_data0 = h_data0;
    thrust::device_vector<T> d_data1 = h_data1;

    typedef tuple<T,T> Tuple;

    // run on host
    Tuple h_result = thrust::reduce( make_zip_iterator(make_tuple(h_data0.begin(), h_data1.begin())),
                                     make_zip_iterator(make_tuple(h_data0.end(),   h_data1.end())),
                                     make_tuple<T,T>(0,0),
                                     TuplePlus<Tuple>());

    // run on device
    Tuple d_result = thrust::reduce( make_zip_iterator(make_tuple(d_data0.begin(), d_data1.begin())),
                                     make_zip_iterator(make_tuple(d_data0.end(),   d_data1.end())),
                                     make_tuple<T,T>(0,0),
                                     TuplePlus<Tuple>());

    ASSERT_ALMOST_EQUAL(get<0>(h_result), get<0>(d_result));
    ASSERT_ALMOST_EQUAL(get<1>(h_result), get<1>(d_result));
  }
};
VariableUnitTest<TestZipIteratorReduce, ThirtyTwoBitTypes> TestZipIteratorReduceInstance;


template <typename T>
struct TestZipIteratorScan
{
  void operator()(const size_t n)
  {
    thrust::host_vector<T> h_data0 = thrusttest::random_samples<T>(n);
    thrust::host_vector<T> h_data1 = thrusttest::random_samples<T>(n);

    thrust::device_vector<T> d_data0 = h_data0;
    thrust::device_vector<T> d_data1 = h_data1;

    typedef tuple<T,T> Tuple;

    thrust::host_vector<Tuple>   h_result(n);
    thrust::device_vector<Tuple> d_result(n);

    // inclusive_scan
    thrust::inclusive_scan( make_zip_iterator(make_tuple(h_data0.begin(), h_data1.begin())),
                            make_zip_iterator(make_tuple(h_data0.end(),   h_data1.end())),
                            h_result.begin(),
                            TuplePlus<Tuple>());
    thrust::inclusive_scan( make_zip_iterator(make_tuple(d_data0.begin(), d_data1.begin())),
                            make_zip_iterator(make_tuple(d_data0.end(),   d_data1.end())),
                            d_result.begin(),
                            TuplePlus<Tuple>());
    ASSERT_EQUAL_QUIET(h_result, d_result);
   
//    std::cout << "n " << n << demangle(typeid(T).name()) << std::endl;
//    // exclusive_scan
//    thrust::exclusive_scan( make_zip_iterator(make_tuple(h_data0.begin(), h_data1.begin())),
//                            make_zip_iterator(make_tuple(h_data0.end(),   h_data1.end())),
//                            h_result.begin(),
//                            make_tuple<T,T>(0,0),
//                            TuplePlus<Tuple>());
//    thrust::exclusive_scan( make_zip_iterator(make_tuple(d_data0.begin(), d_data1.begin())),
//                            make_zip_iterator(make_tuple(d_data0.end(),   d_data1.end())),
//                            d_result.begin(),
//                            make_tuple<T,T>(0,0),
//                            TuplePlus<Tuple>());
//    ASSERT_EQUAL_QUIET(h_result, d_result);
                            
//    thrust::host_vector<T>   h_result0(n);
//    thrust::host_vector<T>   h_result1(n);
//    thrust::device_vector<T> d_result0(n);
//    thrust::device_vector<T> d_result1(n);
//    
//    thrust::inclusive_scan( make_zip_iterator(make_tuple(h_data0.begin(), h_data1.begin())),
//                            make_zip_iterator(make_tuple(h_data0.end(),   h_data1.end())),
//                            h_result.begin(),
//                            TuplePlus<Tuple>());
//    thrust::inclusive_scan( make_zip_iterator(make_tuple(d_data0.begin(), d_data1.begin())),
//                            make_zip_iterator(make_tuple(d_data0.end(),   d_data1.end())),
//                            d_result.begin(),
//                            TuplePlus<Tuple>());
//    ASSERT_EQUAL_QUIET(h_result, d_result);

  }
};
VariableUnitTest<TestZipIteratorScan, SignedIntegralTypes> TestZipIteratorScanInstance;


void TestZipIteratorCopyAoSToSoA(void)
{
  const size_t n = 1;

  typedef tuple<int,int> structure;
  typedef host_vector<structure>   host_array_of_structures;
  typedef device_vector<structure> device_array_of_structures;

  typedef experimental::zip_iterator<
    tuple<host_vector<int>::iterator, host_vector<int>::iterator>
  > host_structure_of_arrays;

  typedef experimental::zip_iterator<
    tuple<device_vector<int>::iterator, device_vector<int>::iterator>
  > device_structure_of_arrays;

  host_array_of_structures   h_aos(n, make_tuple(7, 13) );
  device_array_of_structures d_aos(n, make_tuple(7, 13) );



  // host to host
  host_vector<int> h_field0(n), h_field1(n);
  host_structure_of_arrays h_soa = experimental::make_zip_iterator( make_tuple(h_field0.begin(), h_field1.begin()) );

  thrust::copy(h_aos.begin(), h_aos.end(), h_soa);
  ASSERT_EQUAL_QUIET(make_tuple(7, 13), h_soa[0]);



  // host to device
  device_vector<int> d_field0(n), d_field1(n);
  device_structure_of_arrays d_soa = experimental::make_zip_iterator( make_tuple(d_field0.begin(), d_field1.begin()) );

  thrust::copy(h_aos.begin(), h_aos.end(), d_soa);
  ASSERT_EQUAL_QUIET(make_tuple(7, 13), d_soa[0]);



  // device to device
  thrust::fill(d_field0.begin(), d_field0.end(), 0);
  thrust::fill(d_field1.begin(), d_field1.end(), 0);

  thrust::copy(d_aos.begin(), d_aos.end(), d_soa);
  ASSERT_EQUAL_QUIET(make_tuple(7, 13), d_soa[0]);


  // device to host
  thrust::fill(h_field0.begin(), h_field0.end(), 0);
  thrust::fill(h_field1.begin(), h_field1.end(), 0);

  thrust::copy(d_aos.begin(), d_aos.end(), h_soa);
  ASSERT_EQUAL_QUIET(make_tuple(7, 13), h_soa[0]);
};
DECLARE_UNITTEST(TestZipIteratorCopyAoSToSoA);



void TestZipIteratorCopySoAToAoS(void)
{
  const size_t n = 1;

  typedef tuple<int,int> structure;
  typedef host_vector<structure>   host_array_of_structures;
  typedef device_vector<structure> device_array_of_structures;

  typedef experimental::zip_iterator<
    tuple<host_vector<int>::iterator, host_vector<int>::iterator>
  > host_structure_of_arrays;

  typedef experimental::zip_iterator<
    tuple<device_vector<int>::iterator, device_vector<int>::iterator>
  > device_structure_of_arrays;

  host_vector<int>   h_field0(n, 7), h_field1(n, 13);
  device_vector<int> d_field0(n, 7), d_field1(n, 13);

  host_structure_of_arrays   h_soa = experimental::make_zip_iterator(make_tuple(h_field0.begin(), h_field1.begin()));
  device_structure_of_arrays d_soa = experimental::make_zip_iterator(make_tuple(d_field0.begin(), d_field1.begin()));

  host_array_of_structures   h_aos(n);
  device_array_of_structures d_aos(n);



  // host to host
  thrust::fill(h_aos.begin(), h_aos.end(), make_tuple(0,0));

  thrust::copy(h_soa, h_soa + n, h_aos.begin());
  ASSERT_EQUAL_QUIET(7,  get<0>(h_soa[0]));
  ASSERT_EQUAL_QUIET(13, get<1>(h_soa[0]));



  // host to device
  thrust::fill(d_aos.begin(), d_aos.end(), make_tuple(0,0));

  thrust::copy(h_soa, h_soa + n, d_aos.begin());
  ASSERT_EQUAL_QUIET(7,  get<0>(d_soa[0]));
  ASSERT_EQUAL_QUIET(13, get<1>(d_soa[0]));



  // device to device
  thrust::fill(d_aos.begin(), d_aos.end(), make_tuple(0,0));

  thrust::copy(d_soa, d_soa + n, d_aos.begin());
  ASSERT_EQUAL_QUIET(7,  get<0>(d_soa[0]));
  ASSERT_EQUAL_QUIET(13, get<1>(d_soa[0]));



  // device to host
  thrust::fill(h_aos.begin(), h_aos.end(), make_tuple(0,0));

  thrust::copy(d_soa, d_soa + n, h_aos.begin());
  ASSERT_EQUAL_QUIET(7,  get<0>(h_soa[0]));
  ASSERT_EQUAL_QUIET(13, get<1>(h_soa[0]));
};
DECLARE_UNITTEST(TestZipIteratorCopySoAToAoS);


template <typename T>
  struct TestZipIteratorStableSort
{
  void operator()(const size_t n)
  {
    KNOWN_FAILURE;
//      thrust::host_vector<T>   h1 = thrusttest::random_integers<T>(n);
//      thrust::host_vector<T>   h2 = thrusttest::random_integers<T>(n);
//      thrust::host_vector<T>   h3 = thrusttest::random_integers<T>(n);
//      
//      thrust::device_vector<T> d1 = h1;
//      thrust::device_vector<T> d2 = h2;
//      thrust::device_vector<T> d3 = h3;
//      
//      // Tuples with two elements
//      thrust::stable_sort( make_zip_iterator(make_tuple(h1.begin(), h2.begin())),
//                           make_zip_iterator(make_tuple(h1.end(),   h2.end())) );
//  //    thrust::stable_sort( make_zip_iterator(make_tuple(d1.begin(), d2.begin())),
//  //                         make_zip_iterator(make_tuple(d1.end(),   d2.end())) );
//  //
//  //    ASSERT_EQUAL_QUIET(h1, d1);
//  //    ASSERT_EQUAL_QUIET(h2, d2);
//  
//      // Tuples with three
//      thrust::stable_sort( make_zip_iterator(make_tuple(h1.begin(), h2.begin(), h3.begin())),
//                           make_zip_iterator(make_tuple(h1.end(),   h2.end(),   h3.end())) );
//  //    thrust::stable_sort( make_zip_iterator(make_tuple(d1.begin(), d2.begin(), d3.begin())),
//  //                         make_zip_iterator(make_tuple(d1.end(),   d2.end(),   d3.end())) );
//  //
//  //    ASSERT_EQUAL_QUIET(h1, d1);
//  //    ASSERT_EQUAL_QUIET(h2, d2);
//  //    ASSERT_EQUAL_QUIET(h3, d3);
  }
};
VariableUnitTest<TestZipIteratorStableSort, NumericTypes> TestZipIteratorStableSortInstance;

