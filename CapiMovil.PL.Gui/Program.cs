using CapiMovil.BL.BC;
using System.Globalization;
using CapiMovil.BL.BE;
using CapiMovil.DL.DALC;

CultureInfo.DefaultThreadCurrentCulture =
    CultureInfo.GetCultureInfo("en-US");

CultureInfo.DefaultThreadCurrentUICulture =
    CultureInfo.GetCultureInfo("es-PE");

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllersWithViews();



builder.Services.AddScoped<BDConexion>();


builder.Services.AddScoped<RolBC>();
builder.Services.AddScoped<RolDALC>();

builder.Services.AddScoped<UsuarioBC>();
builder.Services.AddScoped<UsuarioDALC>();

builder.Services.AddScoped<PadreFamiliaBC>();
builder.Services.AddScoped<PadreFamiliaDALC>();

builder.Services.AddScoped<ConductorDALC>();
builder.Services.AddScoped<ConductorBC>();

builder.Services.AddScoped<BusDALC>();
builder.Services.AddScoped<BusBC>();

builder.Services.AddScoped<RutaDALC>();
builder.Services.AddScoped<RutaBC>();

builder.Services.AddScoped<ParaderoDALC>();
builder.Services.AddScoped<ParaderoBC>();

builder.Services.AddScoped<RecorridoDALC>();
builder.Services.AddScoped<RecorridoBC>();

builder.Services.AddScoped<RutaEstudianteDALC>();
builder.Services.AddScoped<RutaEstudianteBC>();

builder.Services.AddScoped<EventoAbordajeDALC>();
builder.Services.AddScoped<EventoAbordajeBC>();

builder.Services.AddScoped<UbicacionBusDALC>();
builder.Services.AddScoped<UbicacionBusBC>();

builder.Services.AddScoped<EstudianteBC>();
builder.Services.AddScoped<EstudianteDALC>();


builder.Services.AddScoped<IncidenciaDALC>();
builder.Services.AddScoped<IncidenciaBC>();

builder.Services.AddScoped<NotificacionDALC>();
builder.Services.AddScoped<NotificacionBC>();

builder.Services.AddScoped<AuditoriaDALC>();
builder.Services.AddScoped<AuditoriaBC>();
builder.Services.AddScoped<CalificacionConductorDALC>();
builder.Services.AddScoped<CalificacionConductorBC>();


builder.Services.AddDistributedMemoryCache();


builder.Services.AddSession(options =>
{
    options.IdleTimeout = TimeSpan.FromMinutes(30);
    options.Cookie.HttpOnly = true;
    options.Cookie.IsEssential = true;
});


builder.Services.AddHttpContextAccessor();


var app = builder.Build();

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}


app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseRouting();
app.UseSession();
app.UseAuthorization();

/*app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");*/

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Auth}/{action=Login}/{id?}");

/*
 * Inicialización opcional para una base recién creada.
 * Defina CAPIMOVIL_ADMIN_PASSWORD solo durante el primer inicio; nunca se
 * guarda la contraseña en appsettings.json ni en el repositorio.
 */
string? adminInicialPassword = Environment.GetEnvironmentVariable("CAPIMOVIL_ADMIN_PASSWORD");
if (!string.IsNullOrWhiteSpace(adminInicialPassword))
{
    using IServiceScope scope = app.Services.CreateScope();
    UsuarioDALC usuarioDALC = scope.ServiceProvider.GetRequiredService<UsuarioDALC>();

    if (usuarioDALC.ObtenerPorUsuarioOCorreo("admin") == null)
    {
        UsuarioBC usuarioBC = scope.ServiceProvider.GetRequiredService<UsuarioBC>();
        usuarioBC.Registrar(new UsuarioBE
        {
            IdRol = Guid.Parse("11111111-1111-1111-1111-111111111111"),
            Username = "admin",
            Correo = "admin@capimovil.local",
            PasswordHash = adminInicialPassword,
            Estado = true
        });
    }
}

app.Run();
