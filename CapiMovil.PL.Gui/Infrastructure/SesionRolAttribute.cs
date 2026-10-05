using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace CapiMovil.PL.Gui.Infrastructure
{
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Method, AllowMultiple = false, Inherited = true)]
    public sealed class SesionRolAttribute : ActionFilterAttribute
    {
        private readonly string[] _rolesPermitidos;

        public SesionRolAttribute(params string[] rolesPermitidos)
        {
            _rolesPermitidos = rolesPermitidos ?? Array.Empty<string>();
        }

        public override void OnActionExecuting(ActionExecutingContext context)
        {
            ISession session = context.HttpContext.Session;

            if (!AutenticacionSesion.TieneSesionActiva(session))
            {
                context.Result = new RedirectToActionResult("Login", "Auth", null);
                return;
            }

            if (_rolesPermitidos.Length > 0 && !AutenticacionSesion.RolPermitido(session, _rolesPermitidos))
                context.Result = new RedirectToActionResult("AccesoDenegado", "Auth", null);
        }
    }
}
