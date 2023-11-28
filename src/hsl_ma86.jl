mutable struct Ma86Solver{T} <: HslSolver{T}
  keep::Ref{Ptr{Cvoid}}
  control::ma86_control{T}
  info::ma86_info{T}

  function Ma86Solver{T}() where T <: BlasReal
    keep = Ref{Ptr{Cvoid}}()
    control = ma86_control{T}()
    info = ma86_info{T}()
    solver = new(keep, control, info)
    default_control(solver)
    finalizer(finalise, solver)
  end
end

for (fname, elty) in ((:ma86_default_control_s, :Float32),
                      (:ma86_default_control_d, :Float64),
                      (:ma86_default_control_c, :ComplexF32),
                      (:ma86_default_control_z, :ComplexF64))
  @eval begin
    function default_control(solver::Ma86Solver{$elty})
      $fname(solver.control)
      solver.control.f_arrays = 1
      return solver
    end
  end
end

for (fname, elty) in ((:ma86_analyse_s, :Float32),
                      (:ma86_analyse_d, :Float64),
                      (:ma86_analyse_c, :ComplexF32),
                      (:ma86_analyse_z, :ComplexF64))
  @eval begin
    function analyse(solver::Ma86Solver{$elty}, A::SparseMatrixCSC{$elty})
      n = checksquare(A)
      $fname(n, A.colptr, A.rowval, order, solver.keep, solver.control, solver.info)
      return solver
    end

    analyze(solver::Ma86Solver{$elty}, A::SparseMatrixCSC{$elty}) = analyse(solver, A)
  end
end

for (fname, elty) in ((:ma86_factor_s, :Float32),
                      (:ma86_factor_d, :Float64),
                      (:ma86_factor_c, :ComplexF32),
                      (:ma86_factor_z, :ComplexF64))
  @eval begin
    function factorise(solver::Ma86Solver{$elty}, A::SparseMatrixCSC{$elty})
      n = checksquare(A)
      $fname(matrix_type, n, A.colptr, A.rowval, A.nzval, order, solver.keep, solver.control, solver.info, scale)
      return solver
    end

    factorize(solver::Ma86Solver{$elty}, A::SparseMatrixCSC{$elty}) = factorise(solver, A)
  end
end

for (fname, elty) in ((:ma86_factor_solve_s, :Float32),
                      (:ma86_factor_solve_d, :Float64),
                      (:ma86_factor_solve_c, :ComplexF32),
                      (:ma86_factor_solve_z, :ComplexF64))
  @eval begin
    function factorise_solve(solver::Ma86Solver{$elty}, A::SparseMatrixCSC{$elty})
      n = checksquare(A)
      $fname(matrix_type, n, A.colptr, A.rowval, A.nzval, order, keep, control, info, nrhs, ldx, x, scale)
      return solver
    end

    factorize_solve(solver::Ma86Solver{$elty}, A::SparseMatrixCSC{$elty}) = factorise_solve(solver, A)
  end
end

for (fname, elty) in ((:ma86_solve_s, :Float32),
                      (:ma86_solve_d, :Float64),
                      (:ma86_solve_c, :ComplexF32),
                      (:ma86_solve_z, :ComplexF64))
  @eval begin
    function solve(solver::Ma86Solver{$elty}, x::Vector{$elty})
      $fname(job, 1, ldx, x, order, solver.keep, solver.control, solver.info, scale)
      return solver
    end

    function solve(solver::Ma86Solver{$elty}, X::Matrix{$elty})
      nrhs = size(X,2)
      $fname(job, nrhs, ldx, X, order, solver.keep, solver.control, solver.info, scale)
      return solver
    end
  end
end

for (fname, elty) in ((:ma86_finalise_s, :Float32),
                      (:ma86_finalise_d, :Float64),
                      (:ma86_finalise_c, :ComplexF32),
                      (:ma86_finalise_z, :ComplexF64))
  @eval begin
    function finalise(solver::Ma86Solver{$elty})
      $fname(solver.keep, solver.control)
      return solver
    end

    finalize(solver::Ma86Solver{$elty}) = finalise(solver)
  end
end
