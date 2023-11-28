mutable struct Ma57Solver{T} <: HslSolver{T}
  factors::Ref{Ptr{Cvoid}}
  control::ma57_control{T}
  ainfo::ma57_ainfo{T}
  finfo::ma57_finfo{T}
  sinfo::ma57_sinfo{T}

  function Ma57Solver{T}() where T <: BlasReal
    factors = Ref{Ptr{Cvoid}}()
    control = ma57_control{T}()
    ainfo = ma57_ainfo{T}()
    finfo = ma57_finfo{T}()
    sinfo = ma57_sinfo{T}()
    solver = new(factors, control, ainfo, finfo, sinfo)
    initialise(solver)
    default_control(solver)
    finalizer(finalise, solver)
    return solver
  end
end

# ma57_enquire_perm_d
# ma57_enquire_pivots_d
# ma57_enquire_d_d
# ma57_enquire_perturbation_d
# ma57_enquire_scaling_d
# ma57_alter_d_d
# ma57_part_solve_d
# ma57_sparse_lsolve_d
# ma57_fredholm_alternative_d
# ma57_lmultiply_d
# ma57_get_factors_d

for (fname, elty) in ((:ma57_init_factors_s, :Float32),
                      (:ma57_init_factors_d, :Float64))
  @eval begin
    function initialise(solver::Ma57Solver{$elty})
      $fname(solver.factors)
      return solver
    end

    initialize(solver::Ma57Solver{$elty}) = initialise(solver)
  end
end

for (fname, elty) in ((:ma57_default_control_s, :Float32),
                      (:ma57_default_control_d, :Float64))
  @eval begin
    function default_control(solver::Ma57Solver{$elty})
      $fname(solver.control)
      solver.control.f_arrays = 1
      return solver
    end
  end
end

for (fname, elty) in ((:ma57_analyse_s, :Float32),
                      (:ma57_analyse_d, :Float64))
  @eval begin
    function analyse(solver::Ma57Solver{$elty}, A::SparseMatrixCSC{$elty}; permutation=C_NULL)
      n = checksquare(A)
      ne = nnz(A)
      $fname(n, ne, A.colptr, A.rowval, solver.factors, solver.control, solver.ainfo, permutation)
      return solver
    end

    analyze(solver::Ma57Solver{$elty}, A::SparseMatrixCSC{$elty}) = analyse(solver, A)
  end
end

for (fname, elty) in ((:ma57_factorize_s, :Float32),
                      (:ma57_factorize_d, :Float64))
  @eval begin
    function factorise(solver::Ma57Solver{$elty}, A::SparseMatrixCSC{$elty})
      n = checksquare(A)
      ne = nnz(A)
      $fname(n, ne, A.rowval, A.colptr, A.nzval, solver.factors, solver.control, solver.finfo)
      return solver
    end

    factorize(solver::Ma57Solver{$elty}, A::SparseMatrixCSC{$elty}) = factorise(solver, A)
  end
end

for (fname, elty) in ((:ma57_solve_s, :Float32),
                      (:ma57_solve_d, :Float64))
  @eval begin
    function solve(solver::Ma57Solver{$elty}, A::SparseMatrixCSC{$elty}, x::Vector{$elty}, b::Vector{$elty}; iter::Int=0, cond::Bool=false)
      n = checksquare(A)
      ne = nnz(A)
      $fname(n, nnz(A), A.rowval, A.colptr, A.nzval, solver.factors, 1, x, solver.control, solver.sinfo, b, iter, cond)
      return solver
    end

    function solve(solver::Ma57Solver{$elty}, A::SparseMatrixCSC{$elty}, X::Matrix{$elty}, B::Matrix{$elty}; iter::Int=0, cond::Bool=false)
      n = checksquare(A)
      ne = nnz(A)
      nrhs = size(B,2)
      $fname(n, ne, A.rowval, A.colptr, A.nzval, solver.factors, nrhs, x, solver.control, solver.sinfo, b, iter, cond)
      return solver
    end
  end
end

for (fname, elty) in ((:ma57_finalize_s, :Float32),
                      (:ma57_finalize_d, :Float64))
  @eval begin
    function finalise(solver::Ma57Solver{$elty})
      $fname(solver.factors, solver.control)
      return solver
    end

    finalize(solver::Ma57Solver{$elty}) = finalise(solver)
  end
end
