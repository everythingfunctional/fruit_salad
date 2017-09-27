module greeting_for_test

use fruit

implicit none

contains

subroutine test_greeting_for_prepends_hello_to_a_name
use greeting, only: greeting_for
character(len=:), allocatable :: prompt
allocate(character::prompt)

prompt = greeting_for("World")

call assertEquals("Hello World", prompt)

end subroutine test_greeting_for_prepends_hello_to_a_name

end module greeting_for_test
