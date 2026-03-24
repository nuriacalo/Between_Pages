enum EstadoLectura {
  pendiente("Pendiente"),
  leyendo("Leyendo"),
  terminado("Terminado"),
  abandonado("Abandonado");

  final String value;
  const EstadoLectura(this.value);
}

enum FormatoLectura {
  fisico("Fisico"),
  digital("Digital"),
  audiolibro("Audiolibro");

  final String value;
  const FormatoLectura(this.value);
}
