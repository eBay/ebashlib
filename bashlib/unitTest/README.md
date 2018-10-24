unitTest
========

function battery to conduct some basic unit testing

run `../../examples/example_unitTest.sh` for a demo of the main functionalities

public functions
----------------

### `UT_RUN_TEST_SUITE( description )`

* executes the current test suite and prints a statistic on pass and fail assertions

a sample run will be: 

> * `UT_setUp`                (optional, must be declared as a function with 
>                              exactly this name)
> * `UT_testMy1stFunction`    (first function found that matches the name 
>                              `UT_test[a-zA-Z0-9_]*` )
> * `UT_tearDown`             (optional, must be declared as a function with 
>                              exactly this name) 
> * `UT_setUp`                (as above)
> * `UT_testMy2ndFunction`    (second function found that matches the name 
>                              `UT_test[a-zA-Z0-9_]*` )
> * `UT_tearDown              (as above)

### `UT_ASSERT_EQUAL( description, hypothesis, reference )`

* checks whether hypothesis and reference are equal. 
 * will print a fail notice along with the description if not.

### `UT_SET_REPORT_PASS_ON()`

* setter function to switch reports on passed tests on 

### `UT_SET_REPORT_PASS_OFF()`

* setter function to switch reports on passed tests off
