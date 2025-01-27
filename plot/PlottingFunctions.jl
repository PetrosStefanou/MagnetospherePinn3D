function plot_l2error(resolutions, l2errors)
	fig = Figure(size = (800, 600))
	ax = Axis(fig[1, 1], xlabel = "Resolution", ylabel = "L2 error", xscale = log10, yscale = log10)

	labels = ["Total", L"\hat{r}", L"\hat{\theta}", L"\hat{\phi}", L"\nabla\cdot B", L"B \cdot \nabla \alpha"]

	for (i, l2error) in enumerate(l2errors)
		lines!(ax, resolutions, l2error, label = labels[i])
	end

	scaling_factor = l2errors[1][1] / (resolutions[1]^(-2))
	lines!(ax, resolutions, (resolutions) .^ (-2) .* scaling_factor, label = L"N^{-2}")

	axislegend(ax)
	display(GLMakie.Screen(), fig)
end

function plot_l2error_vs_q(q, l2errors_vs_q)

   n_q = size(q, 1)

	fig = Figure(size = (800, 600))
	ax = Axis(fig[1, 1], xlabel = "q", ylabel = "L2 error", yscale = log10)
	
	labels = ["Total", L"\hat{r}", L"\hat{θ}", L"\hat{ϕ}", L"∇⋅\textbf{B}", L"B \cdot \nabla \alpha"]
	
	for (i, l2) in enumerate(l2errors_vs_q)
		lines!(ax, q[2:n_q-1, 1, 1], l2, label = labels[i], )
	end

	axislegend(ax, position = :lt, merge = true)
	display(GLMakie.Screen(), fig)
end

function plot_l2_errors_vs_μ(μ, l2errors_vs_μ)

	n_μ = size(μ, 2)

	fig = Figure(size = (800, 600))
	ax = Axis(fig[1, 1], xlabel = "μ", ylabel = "L2 error", yscale = log10)
	
	labels = ["Total", L"\hat{r}", L"\hat{θ}", L"\hat{ϕ}", L"∇⋅\textbf{B}", L"B \cdot \nabla \alpha"]
	
	for (i, l2) in enumerate(l2errors_vs_μ)
		lines!(ax, μ[1, 2:n_μ-1, 1], l2, label = labels[i], )
	end

	axislegend(ax, position = :lt, merge = true)
	display(GLMakie.Screen(), fig)
	
end

function plot_l2_errors_vs_ϕ(ϕ, l2errors_vs_ϕ)

	n_ϕ = size(ϕ, 3)

	fig = Figure(size = (800, 600))
	ax = Axis(fig[1, 1], xlabel = "ϕ", ylabel = "L2 error", yscale = log10)
	
	labels = ["Total", L"\hat{r}", L"\hat{θ}", L"\hat{ϕ}", L"∇⋅\textbf{B}", L"B \cdot \nabla \alpha"]
	
	for (i, l2) in enumerate(l2errors_vs_ϕ)
		lines!(ax, ϕ[1, 1, 2:n_ϕ-1], l2, label = labels[i], )
	end	

	axislegend(ax, position = :lt, merge = true)
	display(GLMakie.Screen(), fig)

end

function plot_line(sol, lscene)
   q, μ, ϕ = sol[1,:], sol[2,:], sol[3,:]
   x = @. √abs(1 - μ^2) / q * cos(ϕ)
   y = @. √abs(1 - μ^2) / q * sin(ϕ)
   z = @. μ / q

   lines!(lscene,x, y, z, color=:silver)
end

function plot_fieldlines(fieldlines, lscene)
   for l in eachindex(fieldlines)
      sol = fieldlines[l]
      plot_line(sol, lscene)
   end
end

function plot_surface_α(μ, ϕ, α_surface)
	f = Figure()
	ax = Axis(f[1, 1], xlabel="ϕ", ylabel="μ", title="Surface α")
	cont = contourf!(ϕ[end,1,:], μ[end,:,1], transpose(log10.(abs.(α_surface))), levels=range(-5, 1, 100), colormap=reverse(cgrad(:gist_heat)))
	cbar = Colorbar(f[1, 2], cont, scale=log10)
	tightlimits!(ax)
	display(GLMakie.Screen(), f)
	save(joinpath("figures", "surface_alpha.png"), f)
end


function plot_surface_dα_dt(μ, ϕ, dα_dt)
	f = Figure()
	ax = Axis(f[1, 1], xlabel="ϕ", ylabel="μ", title=L"Surface $\frac{\partial\alpha}{\partial t}$")
	cont = contourf!(ϕ[end,1,:], μ[end,2:end-2,1]
						  , transpose(dα_dt[2:end-2,:])
						  , levels=100
						  , colormap=:plasma)
	cbar = Colorbar(f[1, 2], cont
					    , ticks=range(minimum(dα_dt[2:end-2,:]), maximum(dα_dt[2:end-2,:]), 5)
						 , tickformat = "{:.0f}"
						 )
	tightlimits!(ax)
	display(GLMakie.Screen(), f)
	save(joinpath("figures", "surface_da_dt.png"), f)
end

function plot_surface_diffusive_term(μ, ϕ, diffusive_term)
	f = Figure()
	ax = Axis(f[1, 1], xlabel="ϕ", ylabel="μ", title=L"Surface $\nabla^2 \alpha$")
	cont = contourf!(ϕ[end,1,:], μ[end,2:end-2,1]
						  , transpose(diffusive_term[2:end-2,:])
						  , levels=100
						  , colormap=reverse(cgrad(:thermal))
						 )
	cbar = Colorbar(f[1, 2], cont
						 , ticks=range(minimum(diffusive_term[2:end-2,:]), maximum(diffusive_term[2:end-2,:]), 5)
						 , tickformat = "{:.0f}"
						 )
	tightlimits!(ax)
	display(GLMakie.Screen(), f)
	save(joinpath("figures", "surface_diffusive_term.png"), f)
end

function plot_surface_advective_term(μ, ϕ, advective_term)
	f = Figure()
	ax = Axis(f[1, 1], xlabel="ϕ", ylabel="μ", title=L"Surface \ $\frac{\nabla (B^2) \cdot \nabla \alpha}{B^2}$")
	cont = contourf!(ϕ[end,1,:], μ[end,1:end,1]
						  , transpose(advective_term[1:end,:])
						  , levels=100
						#   , levels=100
						  , colormap=reverse(cgrad(:deep))
						 )
	cbar = Colorbar(f[1, 2], cont
						 , ticks=range(minimum(advective_term[2:end-2,:]), maximum(advective_term[2:end-2,:]), 5)
						 , tickformat = "{:.0f}"
						 )
	tightlimits!(ax)
	display(GLMakie.Screen(), f)
	save(joinpath("figures", "surface_advective_term.png"), f)
end

function plot_surface_Br(μ, ϕ, Br1)
	f = Figure()
	ax = Axis(f[1, 1], xlabel="ϕ", ylabel="μ", title="Surface B")
	cont = contourf!(ϕ[end,1,:], μ[end,:,1], transpose(Br1[end,:,:]), levels = 100, colormap=:blues)
	cbar = Colorbar(f[1, 2], cont)
	tightlimits!(ax)
	display(GLMakie.Screen(), f)
end

function plot_ϕ_slice(x, z, α1)
	ϕ0 = n_ϕ ÷ n_ϕ
	f = Figure()
	ax = Axis(f[1, 1], xlabel="x", ylabel="z", ylabelrotation=0, limits=((0, 5), (-2.5, 2.5)))
	surf = surface!(x[:, :, ϕ0], z[:, :, ϕ0], α1[:, :, ϕ0], colormap=reverse(cgrad(:gist_heat)), shading=NoShading)
	cbar = Colorbar(f[1, 2], surf)
	display(GLMakie.Screen(), f)
end

