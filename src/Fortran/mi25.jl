function mi25id(icntl, cntl, isave, rsave)
  @ccall libhsl.mi25id_(icntl::Ptr{Cint}, cntl::Ptr{Float64}, isave::Ptr{Cint},
                        rsave::Ptr{Float64})::Cvoid
end

function mi25ad(iact, n, w, ldw, locy, locz, resid, icntl, cntl, info, isave, rsave)
  @ccall libhsl.mi25ad_(iact::Ref{Cint}, n::Ref{Cint}, w::Ptr{Float64}, ldw::Ref{Cint},
                        locy::Ptr{Cint}, locz::Ptr{Cint}, resid::Ref{Float64}, icntl::Ptr{Cint},
                        cntl::Ptr{Float64}, info::Ptr{Cint}, isave::Ptr{Cint},
                        rsave::Ptr{Float64})::Cvoid
end

function mi25i(icntl, cntl, isave, rsave)
  @ccall libhsl.mi25i_(icntl::Ptr{Cint}, cntl::Ptr{Float32}, isave::Ptr{Cint},
                       rsave::Ptr{Float32})::Cvoid
end

function mi25a(iact, n, w, ldw, locy, locz, resid, icntl, cntl, info, isave, rsave)
  @ccall libhsl.mi25a_(iact::Ref{Cint}, n::Ref{Cint}, w::Ptr{Float32}, ldw::Ref{Cint},
                       locy::Ptr{Cint}, locz::Ptr{Cint}, resid::Ref{Float32}, icntl::Ptr{Cint},
                       cntl::Ptr{Float32}, info::Ptr{Cint}, isave::Ptr{Cint},
                       rsave::Ptr{Float32})::Cvoid
end
