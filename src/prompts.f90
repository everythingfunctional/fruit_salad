module greeting

implicit none

contains

function greeting_for(name) result(output)
character(len=*), intent(in) :: name
character(len=:), allocatable :: output

output = "Hello " // name

end function greeting_for

end module greeting

module fairwell

implicit none

contains

function fairwell_for(name) result(output)
character(len=*), intent(in) :: name
character(len=:), allocatable :: output

output = "Goodbye " // name

end function fairwell_for

end module fairwell
