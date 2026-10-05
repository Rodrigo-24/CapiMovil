using System.ComponentModel.DataAnnotations;

namespace CapiMovil.PL.Gui.Models.ViewModels
{
    public class UsuarioPasswordViewModel
    {
        public Guid IdUsuario { get; set; }

        [Display(Name = "Código")]
        public string CodigoUsuario { get; set; } = string.Empty;

        [Display(Name = "Username")]
        public string Username { get; set; } = string.Empty;

        [Required(ErrorMessage = "La nueva contraseña es obligatoria.")]
        [StringLength(100, MinimumLength = 8, ErrorMessage = "La contraseña debe tener al menos 8 caracteres.")]
        [DataType(DataType.Password)]
        [Display(Name = "Nueva contraseña")]
        public string PasswordNueva { get; set; } = string.Empty;

        [Required(ErrorMessage = "Debe confirmar la contraseña.")]
        [StringLength(100, MinimumLength = 8, ErrorMessage = "La contraseña debe tener al menos 8 caracteres.")]
        [Compare(nameof(PasswordNueva), ErrorMessage = "Las contraseñas no coinciden.")]
        [DataType(DataType.Password)]
        [Display(Name = "Confirmar contraseña")]
        public string ConfirmarPassword { get; set; } = string.Empty;
    }
}
