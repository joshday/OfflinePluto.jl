# Download links in `assets.csv`

for url in readlines(joinpath(@__DIR__, "assets.csv") )
    @info "Downloading: $url"
    file = touch(joinpath(@__DIR__, "Pluto", "frontend", "offline_assets", basename(url)))
    download(url, file)
end