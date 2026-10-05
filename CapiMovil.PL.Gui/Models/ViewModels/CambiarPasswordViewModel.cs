using System.ComponentModel.DataAnnotations;

namespace CapiMovil.PL.Gui.Models.ViewModels
{
    public class CambiarPasswordViewModel
    {
        public Guid IdUsuario { get; set; }

        [Required(ErrorMessage = "La nueva contraseña es obligatoria.")]
        [StringLength(100, MinimumLength = 8, ErrorMessage = "La contraseña debe tener al menos 8 caracteres.")]
        [DataType(DataType.Password)]
        public string PasswordNueva { get; set; } = string.Empty;

        [Required(ErrorMessage = "La confirmación de contraseña es obligatoria.")]
        [StringLength(100, MinimumLength = 8, ErrorMessage = "La contraseña debe tener al menos 8 caracteres.")]
        [DataType(DataType.Password)]
        [Compare("PasswordNueva", ErrorMessage = "Las contraseñas no coinciden.")]
        public string ConfirmarPassword { get; set; } = string.Empty;
    }
}
