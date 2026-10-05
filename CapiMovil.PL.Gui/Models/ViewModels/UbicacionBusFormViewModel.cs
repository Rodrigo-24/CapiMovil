using Microsoft.AspNetCore.Mvc.Rendering;
using System.ComponentModel.DataAnnotations;

namespace CapiMovil.PL.Gui.Models.ViewModels
{
    public class UbicacionBusFormViewModel
    {
        public Guid IdUbicacion { get; set; }

        [Required(ErrorMessage = "Debe seleccionar un recorrido.")]
        [Display(Name = "Recorrido")]
        public Guid IdRecorrido { get; set; }

        [Display(Name = "Código")]
        public string CodigoUbicacion { get; set; } = string.Empty;

        [Required(ErrorMessage = "La latitud es obligatoria.")]
        [Display(Name = "Latitud")]
        [Range(-90d, 90d, ErrorMessage = "La latitud debe estar entre -90 y 90.")]
        public decimal Latitud { get; set; }

        [Required(ErrorMessage = "La longitud es obligatoria.")]
        [Display(Name = "Longitud")]
        [Range(-180d, 180d, ErrorMessage = "La longitud debe estar entre -180 y 180.")]
        public decimal Longitud { get; set; }

        [Display(Name = "Velocidad")]
        public decimal? Velocidad { get; set; }

        [Display(Name = "Precisión (m)")]
        public decimal? PrecisionMetros { get; set; }

        [Required(ErrorMessage = "La fecha y hora son obligatorias.")]
        [Display(Name = "Fecha y Hora")]
        public DateTime FechaHora { get; set; } = DateTime.Now;

        [Display(Name = "Fuente")]
        public string? Fuente { get; set; } = "MANUAL";

        [Display(Name = "Estado")]
        public bool Estado { get; set; } = true;

        public List<SelectListItem> Recorridos { get; set; } = new();
        public List<SelectListItem> Fuentes { get; set; } = new();
    }
}
