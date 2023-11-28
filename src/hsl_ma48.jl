mutable struct Ma48Solver{T} <: HslSolver{T}
  factors::Ref{Ptr{Cvoid}}
  control::ma48_control{T}
  ainfo::ma48_ainfo{T}
  finfo::ma48_finfo{T}

  function Ma48Solver{T}() where T <: BlasFloat
    factors = Ref{Ptr{Cvoid}}()
    control = ma48_control{T}()
    ainfo = ma48_ainfo{T}()
    finfo = ma48_finfo{T}()
    solver = new(factors, control, ainfo, finfo)
    initialise(solver)
    default_control(solver)
    finalizer(finalise, solver)
    return solver
  end
end

for (fname, elty) in ((:ma48_initialize_s, :Float32),
                      (:ma48_initialize_d, :Float64))
  @eval begin
    function initialise(solver::Ma48Solver{$elty})
      $fname(solver.factors)
      return solver
    end

    initialize(solver::Ma48Solver{$elty}) = initialise(solver)
  end
end

for (fname, elty) in ((:ma48_default_control_s, :Float32),
                      (:ma48_default_control_d, :Float64))
  @eval begin
    function default_control(solver::Ma48Solver{$elty})
      $fname(solver.control)
      solver.control.f_arrays = 1
      return solver
    end
  end
end

for (fname, elty) in ((:ma48_analyse_s, :Float32),
                      (:ma48_analyse_d, :Float64))
  @eval begin
    function analyse(solver::Ma48Solver{$elty}, A::SparseMatrixCSC{$elty}; permutation=C_NULL, endcol=C_NULL)
      m, n = size(A)
      ne = nnz(A)
      $fname(m, n, ne, A.rowval, A.colptr, A.nzval, solver.factors, solver.control, solver.ainfo, solver.finfo, permutation, endcol)
      return solver
    end

    analyze(solver::Ma48Solver{$elty}, A::SparseMatrixCSC{$elty}; permutation=C_NULL, endcol=C_NULL) = analyse(solver, A, permutation, endcol)
  end
end

for (fname, elty) in ((:ma48_factorize_s, :Float32),
                      (:ma48_factorize_d, :Float64))
  @eval begin
    function factorise(solver::Ma48Solver{$elty}, A::SparseMatrixCSC{$elty}; fast::Bool=false, partial::Bool=false)
      m, n = size(A)
      ne = nnz(A)
      $fname(m, n, ne, A.rowval, A.colptr, A.nzval, solver.factors, solver.control, solver.finfo, fast, partial)
      return solver
    end

    factorize(solver::Ma48Solver{$elty}, A::SparseMatrixCSC{$elty}; fast::Bool=false, partial::Bool=false) = factorise(solver)
  end
end

for (fname, elty) in ((:ma48_solve_s, :Float32),
                      (:ma48_solve_d, :Float64))
  @eval begin
    function solve(solver::Ma48Solver{$elty}, A::SparseMatrixCSC{$elty}, x::Vector{$elty}, b::Vector{$elty}; trans::Bool=false, resid=C_NULL, error=C_NULL)
      m, n = size(A)
      ne = nnz(A)
      $fname(m, n, ne, A.rowval, A.colptr, A.nzval, solver.factors, b, x, solver.control, solver.sinfo, trans, resid, error)
      return solver
    end
  end
end

for (fname, elty) in ((:ma48_finalize_s, :Float32),
                      (:ma48_finalize_d, :Float64))
  @eval begin
    function finalise(solver::Ma48Solver{$elty})
      $fname(solver.factors, solver.control)
      return solver
    end

    finalize(solver::Ma48Solver{$elty}) = finalise(solver)
  end
end

# for (fname, elty) in ((:ma48_get_perm_s, :Float32),
#                       (:ma48_get_perm_d, :Float64))
#   @eval begin
#     function get_perm(solver::Ma48Solver{$elty})
#       $fname(solver)
#       return solver
#     end
#   end
# end

# for (fname, elty) in ((:ma48_special_rows_and_cols_s, :Float32),
#                       (:ma48_special_rows_and_cols_d, :Float64))
#   @eval begin
#     function special_rows_and_cols(solver::Ma48Solver{$elty})
#       $fname(solver)
#       return solver
#     end
#   end
# end

# for (fname, elty) in ((:ma48_determinant_s, :Float32),
#                       (:ma48_determinant_d, :Float64))
#   @eval begin
#     function determinant(solver::Ma48Solver{$elty})
#       $fname(solver)
#       return solver
#     end
#   end
# end
