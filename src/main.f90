program example
use greeting, only: greeting_for
use fairwell, only: fairwell_for

implicit none

character(len=*), parameter :: name = "World"
character(len=:), allocatable :: greeting_, fairwell_
allocate(character::greeting_)
allocate(character::fairwell_)

greeting_ = greeting_for(name)
fairwell_ = fairwell_for(name)

print *, greeting_
print *, fairwell_

end program example
