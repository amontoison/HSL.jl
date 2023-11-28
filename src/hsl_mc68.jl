mutable struct Mc68
  control::mc68_control
  info::mc68_info
end

function Mc68()
  control = mc68_control()
  info = mc68_info()
  solver = new(control, info)
  default_control(solver)
  return solver
end

for (fname, elty) in ((:mc68_default_control_i, :Cint),)
  @eval begin
    function default_control(solver::Mc68)
      $fname(solver.control)
      solver.control.f_arrays = 1
      return solver
    end
  end
end

# for (fname, elty) in ((:mc68_order_i, :Cint),)
#   @eval begin
#     function order(solver::Mc68, ...)
#       $fname(ord, n, ptr, row, perm, solver.control, solver.info)
#       return solver
#     end
#   end
# end
