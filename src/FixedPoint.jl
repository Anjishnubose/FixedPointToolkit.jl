module FPoint

    export FixedPoint!, ContinueFixedPoint!

    using ..FixedPointToolkit.SelfConsistency: SelfCons
    using ..FixedPointToolkit.Checkpointer: save_checkpoint, read_checkpoint, ReCreateSelfCons  
    
    using Logging


@doc """
```julia
FixedPoint!(SC::SelfCons; tol::Float64=1e-6, max_iter::Int64=100) 
FixedPoint!(SC::SelfCons, fileName::String; tol::Float64=1e-6, max_iter::Int64=100, checkpoint_interval::Int64 = 10) 
```

Runs a fixed point iteration on the `SelfCons` SC with a convergence tolerance of `tol` per input, and a maximum iteration cutoff of `max_iter`.
Optionally can also pass a `fileName` to checkpoint and save the results in. Can pass a kwarg `checkpoint_interval` to set the checkpoint frequency.

"""
    function FixedPoint!(SC::SelfCons; tol::Float64=1e-6, max_iter::Int64=100) 

        SelfConsParams  =   Dict(:iter => 0, :max_iter => max_iter)

        @info "Beginning Iterations..."
        for iter in 1:max_iter

            SelfConsParams[:iter]  =   SelfConsParams[:iter] + 1

            updates =   SC.Update(SC.VIns[end], SC.VOuts[end], SC.F ; F_args = SC.F_args, F_kwargs = SC.F_kwargs, SC.Update_kwargs..., SelfConsParams...)

            SC.Update_kwargs  =   get(updates, "kwargs", SC.Update_kwargs)
            SC.F_args         =   get(updates, "F_args", SC.F_args)
            SC.F_kwargs       =   get(updates, "F_kwargs", SC.F_kwargs)

            push!(SC.VIns, updates["VInNext"])
            push!(SC.VOuts, updates["VOutNext"])

            if updates["Delta"] < tol
                @info "Converged within tolerance = $(tol)"
                break
            end

        end

    end

    function FixedPoint!(SC::SelfCons, fileName::String; tol::Float64=1e-6, max_iter::Int64=100, checkpoint_interval::Int64 = 10, _extra...) 

        SelfConsParams  =   Dict(:iter => 0, :max_iter => max_iter, :tol => tol, :checkpoint_interval => checkpoint_interval)

        @info "Beginning Iterations..."
        for iter in 1:max_iter

            SelfConsParams[:iter]  =   SelfConsParams[:iter] + 1

            updates =   SC.Update(SC.VIns[end], SC.VOuts[end], SC.F ; F_args = SC.F_args, F_kwargs = SC.F_kwargs, SC.Update_kwargs..., SelfConsParams...)

            SC.Update_kwargs  =   get(updates, "kwargs", SC.Update_kwargs)
            SC.F_args         =   get(updates, "F_args", SC.F_args)
            SC.F_kwargs       =   get(updates, "F_kwargs", SC.F_kwargs)

            push!(SC.VIns, updates["VInNext"])
            push!(SC.VOuts, updates["VOutNext"])

            if iter == 1 || (iter % checkpoint_interval) == 0 || iter == max_iter
                save_checkpoint(fileName, SC, SelfConsParams)
                @info "Checkpoint Saved in $(fileName)."
            end

            if updates["Delta"] < tol
                @info "Converged within tolerance = $(tol)"

                save_checkpoint(fileName, SC, SelfConsParams)
                @info "Result Saved in $(fileName)."

                break
            end

        end

    end


@doc """
```julia
ContinueFixedPoint!(fileName::String, F::T, Update::R) where {T<:Function, R<:Function}
```

Reruns a fixed point iteration on the `SelfCons` reconstructed from the checkpoint saved in the JLD2 file `fileName`.

"""
    function ContinueFixedPoint!(fileName::String, F::T, Update::R) where {T<:Function, R<:Function}

        checkpoint      =   read_checkpoint(fileName)
        SelfConsParams  =   checkpoint["Self-consistency params"]
        SC              =   ReCreateSelfCons(checkpoint, F, Update)

        @info "Resuming..."
        FixedPoint!(SC, fileName; SelfConsParams...)

        return SC
    end

    function ContinueFixedPoint!(fileName::String, F::T, Update::R, SelfConsParams::Dict{Symbol, Real}) where {T<:Function, R<:Function}

        checkpoint      =   read_checkpoint(fileName)
        SC              =   ReCreateSelfCons(checkpoint, F, Update)

        @info "Resuming ..."
        FixedPoint!(SC, fileName; SelfConsParams...)

        return SC
    end








end