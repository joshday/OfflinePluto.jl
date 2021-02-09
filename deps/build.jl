using Pluto

#-----------------------------------------------------------------------------# Copy Pluto files
@info "Copying Pluto source code..."
pluto_src = abspath(joinpath(pathof(Pluto), "..", ".."))
pluto_dest = joinpath(@__DIR__(), "Pluto")
@info "Copying $pluto_src -> $pluto_dest"
cp(pluto_src, pluto_dest, force=true)

#-----------------------------------------------------------------------------# make edits
@info "Replacing CDN links..."
function _replace(file, old_new::Pair)
    old, new = old_new
    sed = Sys.isapple() ?  ["sed", "-i", ""] : ["sed", "-i"]
    run(`$sed $("s|$old|$new|g") $file`)
end

frontend = joinpath(pluto_dest, "frontend")
assets = joinpath(frontend, "offline_assets")
mkpath(assets)

lines = split(read(`grep -r "jsdelivr" $frontend`, String), '\n')

replaced_assets = []

for line in lines 
    match = findfirst(r"((?<=\")https:\/\/[^\"]*)|((?<=\()https:\/\/[^\)]*)", line)
    if isnothing(match)
        @debug "No match found for line: $line"
    else
        url = line[match]
        push!(replaced_assets, url)
        @info "Downloading: $url"
        file = touch(joinpath(assets, basename(url)))
        try
            write(touch(file), read(`curl --silent /dev/null $url`))
        catch
            @warn "$url didn't want to download..."
        end
        pluto_file = line[1:findfirst(':', line) - 1]
        _replace(pluto_file, url => "/offline_assets/$(basename(file))")
    end
end

#-----------------------------------------------------------------------------# Fix project_relative_path
_replace(
    joinpath(pluto_dest, "src", "Pluto.jl"),
    "pathof(Pluto)" => """joinpath(@__DIR__, "..")"""
)

#-----------------------------------------------------------------------------# Add Plotly
# TODO: This doesn't appear to fix the `Plotly not defined` issue
@info "Writing Plotly.js directly into editor.html"
write(
    touch(joinpath(assets, "plotly-latest.min.js")), 
    read(`curl --silent /dev/null https://cdn.plot.ly/plotly-latest.min.js`)
)

_replace(
    joinpath(frontend, "editor.html"),
    "<head>" => "<head><script src=\"/offline_assets/plotly-latest.min.js\"></script>"
)