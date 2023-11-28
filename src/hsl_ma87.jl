mutable struct Ma87Solver{T} <: HslSolver{T}
  keep::Ref{Ptr{Cvoid}}
  control::ma87_control{T}
  info::ma87_info{T}

  function Ma87Solver{T}() where T <: BlasReal
    keep = Ref{Ptr{Cvoid}}()
    control = ma87_control{T}()
    info = ma87_info{T}()
    solver = new(keep, control, info)
    default_control(solver)
    finalizer(finalise, solver)
  end
end

for (fname, elty) in ((:ma87_default_control_s, :Float32),
                      (:ma87_default_control_d, :Float64),
                      (:ma87_default_control_c, :ComplexF32),
                      (:ma87_default_control_z, :ComplexF64))
  @eval begin
    function default_control(solver::Ma87Solver{$elty})
      $fname(solver.control)
      solver.control.f_arrays = 1
      return solver
    end
  end
end

for (fname, elty) in ((:ma87_analyse_s, :Float32),
                      (:ma87_analyse_d, :Float64),
                      (:ma87_analyse_c, :ComplexF32),
                      (:ma87_analyse_z, :ComplexF64))
  @eval begin
    function analyse(solver::Ma87Solver{$elty}, A::SparseMatrixCSC{$elty})
      n = checksquare(A)
      $fname(n, A.colptr, A.rowval, order, solver.keep, solver.control, solver.info)
      return solver
    end

    analyze(solver::Ma87Solver{$elty}, A::SparseMatrixCSC{$elty}) = analyse(solver, A)
  end
end

for (fname, elty) in ((:ma87_factor_s, :Float32),
                      (:ma87_factor_d, :Float64),
                      (:ma87_factor_c, :ComplexF32),
                      (:ma87_factor_z, :ComplexF64))
  @eval begin
    function factorise(solver::Ma87Solver{$elty}, A::SparseMatrixCSC{$elty})
      n = checksquare(A)
      $fname(n, A.colptr, A.rowval, A.nzval, order, solver.keep, solver.control, solver.info)
      return solver
    end

    factorize(solver::Ma87Solver{$elty}, A::SparseMatrixCSC{$elty}) = factorise(solver, A)
  end
end

for (fname, elty) in ((:ma87_factor_solve_s, :Float32),
                      (:ma87_factor_solve_d, :Float64),
                      (:ma87_factor_solve_c, :ComplexF32),
                      (:ma87_factor_solve_z, :ComplexF64))
  @eval begin
    function factorise_solve(solver::Ma87Solver{$elty}, A::SparseMatrixCSC{$elty})
      n = checksquare(A)
      $fname(n, A.colptr, A.rowval, A.nzval, order, solver.keep, solver.control, solver.info, nrhs, ldx, x)
      return solver
    end

    factorize_solve(solver::Ma87Solver{$elty}, A::SparseMatrixCSC{$elty}) = factorise_solve(solver, A)
  end
end

for (fname, elty) in ((:ma87_solve_s, :Float32),
                      (:ma87_solve_d, :Float64),
                      (:ma87_solve_c, :ComplexF32),
                      (:ma87_solve_z, :ComplexF64))
  @eval begin
    function solve(solver::Ma87Solver{$elty}, x::Vector{$elty})
      $fname(job, 1, ldx, x, order, solver.keep, solver.control, solver.info)
      return solver
    end

    function solve(solver::Ma87Solver{$elty}, X::Matrix{$elty})
      nrhs = size(X,2)
      $fname(job, nrhs, ldx, X, order, solver.keep, solver.control, solver.info)
      return solver
    end
  end
end

for (fname, elty) in ((:ma87_finalise_s, :Float32),
                      (:ma87_finalise_d, :Float64),
                      (:ma87_finalise_c, :ComplexF32),
                      (:ma87_finalise_z, :ComplexF64))
  @eval begin
    function finalise(solver::Ma87Solver{$elty})
      $fname(solver.keep, solver.control)
      return solver
    end

    finalize(solver::Ma87Solver{$elty}) = finalise(solver)
  end
end

# for (fname, elty) in ((:ma87_sparse_fwd_solve_s, :Float32),
#                       (:ma87_sparse_fwd_solve_d, :Float64),
#                       (:ma87_sparse_fwd_solve_c, :ComplexF32),
#                       (:ma87_sparse_fwd_solve_z, :ComplexF64))
#   @eval begin
#     function sparse_fwd_solve(solver::Ma87Solver{$elty})
#       $fname(solver.control)
#       return solver
#     end
#   end
# end
