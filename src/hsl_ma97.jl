mutable struct Ma97Solver{T} <: HslSolver{T}
  akeep::Ref{Ptr{Cvoid}}
  fkeep::Ref{Ptr{Cvoid}}
  control::ma97_control{T}
  info::ma97_info{T}

  function Ma97Solver{T}() where T <: BlasFloat
    akeep = Ref{Ptr{Cvoid}}()
    fkeep = Ref{Ptr{Cvoid}}()
    control = ma97_control{T}()
    info = ma97_info{T}()
    solver = new(akeep, fkeep, control, info)
    default_control(solver)
    finalizer(finalise, solver)
  end
end

# ma97_analyse_coord_d
# ma97_enquire_posdef_d
# ma97_enquire_indef_d
# ma97_free_akeep_d
# ma97_free_fkeep_d
# ma97_alter_d
# ma97_solve_fredholm_d
# ma97_lmultiply_d

for (fname, elty) in ((:ma97_default_control_s, :Float32),
                      (:ma97_default_control_d, :Float64),
                      (:ma97_default_control_c, :ComplexF32),
                      (:ma97_default_control_z, :ComplexF64))
  @eval begin
    function default_control(solver::Ma97Solver{$elty})
      $fname(solver.control)
      solver.control.f_arrays = 1
      return solver
    end
  end
end

for (fname, elty) in ((:ma97_analyse_s, :Float32),
                      (:ma97_analyse_d, :Float64),
                      (:ma97_analyse_c, :ComplexF32),
                      (:ma97_analyse_z, :ComplexF64))
  @eval begin
    function analyse(solver::Ma97Solver{$elty}, A::SparseMatrixCSC{$elty})
      n = checksquare(A)
      $fname(check, n, A.colptr, A.rowval, A.nzval, solver.akeep, solver.control, solver.info, order)
      return solver
    end

    analyze(solver::Ma97Solver{$elty}, A::SparseMatrixCSC{$elty}) = analyse(solver, A)
  end
end

for (fname, elty) in ((:ma97_factor_s, :Float32),
                      (:ma97_factor_d, :Float64),
                      (:ma97_factor_c, :ComplexF32),
                      (:ma97_factor_z, :ComplexF64))
  @eval begin
    function factorise(solver::Ma97Solver{$elty}, A::SparseMatrixCSC{$elty})
      $fname(matrix_type, A.colptr, A.rowval, A.nzval, solver.akeep, solver.fkeep, solver.control, solver.info, scale)
      return solver
    end

    factorize(solver::Ma97Solver{$elty}, A::SparseMatrixCSC{$elty}) = factorise(solver, A)
  end
end

for (fname, elty) in ((:ma97_factor_solve_s, :Float32),
                      (:ma97_factor_solve_d, :Float64),
                      (:ma97_factor_solve_c, :ComplexF32),
                      (:ma97_factor_solve_z, :ComplexF64))
  @eval begin
    function factorise_solve(solver::Ma97Solver{$elty}, A::SparseMatrixCSC{$elty})
      $fname(matrix_type, A.colptr, A.rowval, A.nzval, nrhs, x, ldx, solver.akeep, solver.fkeep, solver.control, solver.info, scale)
      return solver
    end

    factorize_solve(solver::Ma97Solver{$elty}, A::SparseMatrixCSC{$elty}) = factorise_solve(solver, A)
  end
end

for (fname, elty) in ((:ma97_solve_s, :Float32),
                      (:ma97_solve_d, :Float64),
                      (:ma97_solve_c, :ComplexF32),
                      (:ma97_solve_z, :ComplexF64))
  @eval begin
    function solve(solver::Ma97Solver{$elty}, x::Vector{$elty})
      $fname(job, 1, x, ldx, solver.akeep, solver.fkeep, solver.control, solver.info)
      return solver
    end

    function solve(solver::Ma97Solver{$elty}, X::Matrix{$elty})
      nrhs = size(X,2)
      $fname(job, nrhs, X, ldx, solver.akeep, solver.fkeep, solver.control, solver.info)
      return solver
    end
  end
end

for (fname, elty) in ((:ma97_finalise_s, :Float32),
                      (:ma97_finalise_d, :Float64),
                      (:ma97_finalise_c, :ComplexF32),
                      (:ma97_finalise_z, :ComplexF64))
  @eval begin
    function finalise(solver::Ma97Solver{$elty})
      $fname(solver.akeep, solver.fkeep)
      return solver
    end

    finalize(solver::Ma97Solver{$elty}) = finalise(solver)
  end
end

# for (fname, elty) in ((:ma97_sparse_fwd_solve_s, :Float32),
#                       (:ma97_sparse_fwd_solve_d, :Float64),
#                       (:ma97_sparse_fwd_solve_c, :ComplexF32),
#                       (:ma97_sparse_fwd_solve_z, :ComplexF64))
#   @eval begin
#     function sparse_fwd_solve(solver::Ma97Solver{$elty})
#       $fname(solver.control)
#       return solver
#     end
#   end
# end
