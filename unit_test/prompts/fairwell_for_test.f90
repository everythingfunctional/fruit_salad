module fairwell_for_test

use fruit

implicit none

contains

subroutine test_fairwell_for_prepends_goodbye_to_a_name
use fairwell, only: fairwell_for
character(len=:), allocatable :: prompt
allocate(character::prompt)

prompt = fairwell_for("World")

call assertEquals("Goodbye World", prompt)

end subroutine test_fairwell_for_prepends_goodbye_to_a_name

end module fairwell_for_test
