mutable struct Ma77Solver{T} <: HslSolver{T}
  keep::Ref{Ptr{Cvoid}}
  control::ma77_control{T}
  info::ma77_info{T}

  function Ma77Solver{T}() where T <: BlasReal
    keep = Ref{Ptr{Cvoid}}()
    control = ma77_control{T}()
    info = ma77_info{T}()
    solver = new(keep, control, info)
    default_control(solver)
    finalizer(finalise, solver)
    return solver
  end
end

# open_nelt
# open
# input_vars
# input_reals
# enquire_posdef
# enquire_indef
# alter
# restart
# solve_fredholm
# lmultiply

for (fname, elty) in ((:ma77_default_control_s, :Float32),
                      (:ma77_default_control_d, :Float64))
  @eval begin
    function default_control(solver::Ma77Solver{$elty})
      $fname(solver.control)
      solver.control.f_arrays = 1
      return solver
    end
  end
end

for (fname, elty) in ((:ma77_analyse_s, :Float32),
                      (:ma77_analyse_d, :Float64))
  @eval begin
    function analyse(solver::Ma77Solver{$elty})
      $fname(order, solver.keep, solver.control, solver.info)
      return solver
    end

    analyze(solver::Ma77Solver{$elty}) = analyse(solver)
  end
end

for (fname, elty) in ((:ma77_factor_s, :Float32),
                      (:ma77_factor_d, :Float64))
  @eval begin
    function factorise(solver::Ma77Solver{$elty})
      $fname(posdef, keep, control, info, scale)
      return solver
    end

    factorize(solver::Ma77Solver{$elty}) = factorise(solver)
  end
end

for (fname, elty) in ((:ma77_factor_solve_s, :Float32),
                      (:ma77_factor_solve_d, :Float64))
  @eval begin
    function factor_solve(solver::Ma77Solver{$elty})
      $fname(posdef, keep, control, info, scale, nrhs, lx, rhs)
      return solver
    end
  end
end

for (fname, elty) in ((:ma77_solve_s, :Float32),
                      (:ma77_solve_d, :Float64))
  @eval begin
    function solve(solver::Ma77Solver{$elty}, x::Vector{$elty})
      $fname(job, 1, lx, x, solver.keep, solver.control, solver.info, scale)
      return solver
    end

    function solve(solver::Ma77Solver{$elty}, X::Matrix{$elty})
      nrhs = size(X,2)
      $fname(job, nrhs, lx, X, solver.keep, solver.control, solver.info, scale)
      return solver
    end
  end
end

for (fname, elty) in ((:ma77_finalise_s, :Float32),
                      (:ma77_finalise_d, :Float64))
  @eval begin
    function finalise(solver::Ma77Solver{$elty})
      $fname(solver.keep, solver.control, solver.info)
      return solver
    end

    finalize(solver::Ma77Solver{$elty}) = finalise(solver)
  end
end

# for (fname, elty) in ((:ma77_resid_s, :Float32),
#                       (:ma77_resid_d, :Float64))
#   @eval begin
#     function resid(solver::Ma77Solver{$elty})
#       $fname(solver.control)
#       return solver
#     end
#   end
# end

# for (fname, elty) in ((:ma77_scale_s, :Float32),
#                       (:ma77_scale_d, :Float64))
#   @eval begin
#     function scale(solver::Ma77Solver{$elty})
#       $fname(solver.control)
#       return solver
#     end
#   end
# end
