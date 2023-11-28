mutable struct Mc64{T}
  type::T
  control::mc64_control
  info::mc64_info

  function Mc64{T}() where T <: BlasFloat
    control = mc64_control{T}()
    info = mc64_info{T}()
    solver = new(T, control, info)
    default_control(solver)
    return solver
  end
end

for (fname, elty) in ((:mc64_default_control_s, :Float32),
                      (:mc64_default_control_d, :Float64),
                      (:mc64_default_control_c, :ComplexF32),
                      (:mc64_default_control_z, :ComplexF64))
  @eval begin
    function default_control(solver::Mc64{$elty})
      $fname(solver.control)
      solver.control.f_arrays = 1
      return solver
    end
  end
end

# for (fname, elty) in ((:mc64_matching_s, :Float32),
#                       (:mc64_matching_d, :Float64),
#                       (:mc64_matching_c, :ComplexF32),
#                       (:mc64_matching_z, :ComplexF64))
#   @eval begin
#     function matching(solver::Mc64{$elty}, A::SparseMatrixCSC{$elty})
#       $fname(job, matrix_type, A.m, A.n, A.colptr, A.rowval, A.nzval, solver.control, solver.info, perm, scale)
#       return solver
#     end
#   end
# end
