logging
=======

* standardized log level output
* block/plaintext output

run `../../examples/example_logging.sh` for a demo of the main functionalities

public functions
----------------

### `LOGGER_SET_LOG_LEVEL( level )`

setter for the logging level. All messages with equal or higher value will be 
printed to `stderr`. 

| value | variable      | (proposed) meaning                           |
|-------|---------------|----------------------------------------------|
| 999   | `LOG_QUIET`   | no output                                    |
| 40    | `LOG_ERROR`   | script failed                                |
| 30    | `LOG_WARNING` | fishy but non-blocking behaviour             |
| 20    | `LOG_INFO`    | script starting/ending...                    |
| 10    | `LOG_DEBUG`   | function messages, progress update           |
| 0     | `LOG_TRACE`   | verbose logging such as variable contents... |

### `LOGGER ( level, message )`

outputs a message to `stderr` if level is equal or higher than current log level.
Further, messages on `LOG_WARNING` or above will list the executing script/line.

Since stating the level as a separate variable for every invokation can be tedious,
the following convenience functions exist:

* `LOGGER_ERROR ( message )`
* `LOGGER_WARN  ( message )` or `LOGGER_WARNING ( message )`
* `LOGGER_INFO  ( message )`
* `LOGGER_DEBUG ( message )`
* `LOGGER_TRACE ( message )`

### `LOGGER_BLOCK ( message )`

convenience function to output a block message on `LOG_INFO`, which
basically wraps the message into two line separators

