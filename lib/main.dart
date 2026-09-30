import 'package:flutter/material.dart';

void main() => runApp(const TreinoApp());

class TreinoApp extends StatelessWidget {
  const TreinoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Montador de Perfil de Treino',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1769AA),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F8FC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF172033),
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF6F8FC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const TelaMontador(),
    );
  }
}

class _Secao extends StatelessWidget {
  const _Secao({
    required this.icone,
    required this.titulo,
    required this.child,
    this.erro,
  });

  final IconData icone;
  final String titulo;
  final Widget child;
  final String? erro;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: erro != null ? cores.error.withOpacity(.45) : const Color(0xFFE7EAF0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: cores.primary.withOpacity(.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icone, size: 21, color: cores.primary),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF172033),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            child,
            if (erro != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.error_outline, size: 16, color: cores.error),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      erro!,
                      style: TextStyle(color: cores.error, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class TelaMontador extends StatefulWidget {
  const TelaMontador({super.key});

  @override
  State<TelaMontador> createState() => _TelaMontadorState();
}

class _TelaMontadorState extends State<TelaMontador> {
  static const List<String> _metas = [
    'Emagrecimento',
    'Hipertrofia',
    'Condicionamento',
  ];
  static const List<IconData> _iconesMetas = [
    Icons.local_fire_department,
    Icons.fitness_center,
    Icons.directions_run,
  ];
  static const List<String> _experiencias = [
    'Iniciante',
    'Intermediário',
    'Avançado',
  ];
  static const List<String> _dietasDisponiveis = [
    'Vegetariano',
    'Vegano',
    'Sem lactose',
    'Sem glúten',
    'Low Carb',
  ];
  static const List<int> _opcoesDias = [2, 3, 4, 5, 6];

  String? _meta;
  String? _experiencia;
  final Set<String> _dietas = {};
  final List<String> _listaAlergias = [];
  double _minutos = 60;
  int? _diasSemana;
  bool _lembreteAgua = false;
  bool _aceitou = false;

  final TextEditingController _campoAlergia = TextEditingController();
  final FocusNode _focoAlergia = FocusNode();
  String? _msgAlergia;
  bool _tentouGerar = false;

  String? get _erroMeta =>
      _tentouGerar && _meta == null ? 'Escolha um objetivo de treino' : null;

  String? get _erroExperiencia => _tentouGerar && _experiencia == null
      ? 'Informe o seu nível de experiência'
      : null;

  String? get _erroDias => _tentouGerar && _diasSemana == null
      ? 'Selecione a frequência semanal'
      : null;

  String? get _erroTermos => _tentouGerar && !_aceitou
      ? 'Aceite os termos para gerar o plano'
      : null;

  @override
  void dispose() {
    _campoAlergia.dispose();
    _focoAlergia.dispose();
    super.dispose();
  }

  void _incluirAlergia() {
    final nova = _campoAlergia.text.trim();

    if (nova.isEmpty) {
      setState(() => _msgAlergia = 'Escreva o nome da alergia');
      return;
    }

    final repetida = _listaAlergias.any(
      (item) => item.toLowerCase() == nova.toLowerCase(),
    );
    if (repetida) {
      setState(() => _msgAlergia = '"$nova" já está na lista');
      return;
    }

    setState(() {
      _listaAlergias.add(nova);
      _msgAlergia = null;
    });
    _campoAlergia.clear();
    _focoAlergia.requestFocus();
  }

  void _excluirAlergia(String item) {
    setState(() => _listaAlergias.remove(item));
  }

  void _checarCampos() {
    setState(() => _tentouGerar = true);

    final tudoCerto = _meta != null &&
        _experiencia != null &&
        _diasSemana != null &&
        _aceitou;

    if (!tudoCerto) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Falta preencher os campos marcados em vermelho'),
          ),
        );
      return;
    }

    _abrirResumo();
  }

  void _abrirResumo() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: const Color(0xFFF8F9FC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (contextoSheet) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Seu perfil de treino',
                style: Theme.of(contextoSheet).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF172033),
                    ),
              ),
              const SizedBox(height: 8),
              _itemResumo(Icons.flag, 'Objetivo', _meta!),
              _itemResumo(Icons.stairs, 'Nível', _experiencia!),
              _itemResumo(
                Icons.restaurant,
                'Restrições alimentares',
                _dietas.isEmpty ? 'Nenhuma' : _dietas.join(', '),
              ),
              _itemResumo(
                Icons.warning_amber,
                'Alergias',
                _listaAlergias.isEmpty ? 'Nenhuma' : _listaAlergias.join(', '),
              ),
              _itemResumo(
                Icons.timer,
                'Tempo diário',
                '${_minutos.round()} minutos',
              ),
              _itemResumo(
                Icons.calendar_month,
                'Frequência',
                '$_diasSemana dias por semana',
              ),
              _itemResumo(
                Icons.water_drop,
                'Notificações de água',
                _lembreteAgua ? 'Ativadas' : 'Desativadas',
              ),
              _itemResumo(Icons.verified, 'Termos', 'Aceitos'),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.tonal(
                  onPressed: () => Navigator.of(contextoSheet).pop(),
                  child: const Text(
                    'Voltar',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _itemResumo(IconData icone, String rotulo, String valor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icone, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rotulo,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF172033),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Montador de Perfil de Treino',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: cores.primary.withOpacity(.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.fitness_center, color: cores.primary, size: 20),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 18),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cores.primary,
                    cores.primary.withOpacity(.82),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 28,
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Monte seu perfil',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Preencha suas preferências para personalizar seu treino.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            _Secao(
              icone: Icons.flag,
              titulo: 'Objetivo do treino',
              erro: _erroMeta,
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  emptySelectionAllowed: true,
                  showSelectedIcon: false,
                  segments: List.generate(_metas.length, (i) {
                    return ButtonSegment<String>(
                      value: _metas[i],
                      icon: Icon(_iconesMetas[i], size: 18),
                      label: Text(
                        _metas[i],
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11),
                      ),
                    );
                  }),
                  selected: _meta == null ? <String>{} : {_meta!},
                  onSelectionChanged: (escolha) {
                    if (escolha.isNotEmpty) {
                      setState(() => _meta = escolha.first);
                    }
                  },
                ),
              ),
            ),
            _Secao(
              icone: Icons.stairs,
              titulo: 'Nível de experiência',
              erro: _erroExperiencia,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final nivel in _experiencias)
                    ChoiceChip(
                      label: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(nivel),
                      ),
                      selected: _experiencia == nivel,
                      onSelected: (_) => setState(() => _experiencia = nivel),
                    ),
                ],
              ),
            ),
            _Secao(
              icone: Icons.restaurant_menu,
              titulo: 'Restrições alimentares',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final dieta in _dietasDisponiveis)
                    FilterChip(
                      label: Text(dieta),
                      selected: _dietas.contains(dieta),
                      onSelected: (marcado) {
                        setState(() {
                          marcado ? _dietas.add(dieta) : _dietas.remove(dieta);
                        });
                      },
                    ),
                ],
              ),
            ),
            _Secao(
              icone: Icons.warning_amber_rounded,
              titulo: 'Alergias',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _campoAlergia,
                          focusNode: _focoAlergia,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _incluirAlergia(),
                          onChanged: (_) {
                            if (_msgAlergia != null) {
                              setState(() => _msgAlergia = null);
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Digite uma alergia',
                            errorText: _msgAlergia,
                            prefixIcon: const Icon(Icons.search),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: SizedBox(
                          width: 52,
                          height: 52,
                          child: IconButton.filled(
                            tooltip: 'Adicionar alergia',
                            onPressed: _incluirAlergia,
                            icon: const Icon(Icons.add),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_listaAlergias.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        for (final alergia in _listaAlergias)
                          InputChip(
                            label: Text(alergia),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () => _excluirAlergia(alergia),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            _Secao(
              icone: Icons.timer_outlined,
              titulo: 'Tempo diário de treino',
              child: Column(
                children: [
                  Slider(
                    value: _minutos,
                    min: 15,
                    max: 120,
                    divisions: 21,
                    label: '${_minutos.round()} min',
                    onChanged: (valor) => setState(() => _minutos = valor),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Mínimo: 15 min', style: TextStyle(fontSize: 12)),
                        Text('Máximo: 120 min', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: cores.primary.withOpacity(.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'Tempo selecionado: ${_minutos.round()} minutos',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: cores.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _Secao(
              icone: Icons.calendar_month,
              titulo: 'Frequência semanal',
              erro: _erroDias,
              child: RadioGroup<int>(
                groupValue: _diasSemana,
                onChanged: (valor) => setState(() => _diasSemana = valor),
                child: Column(
                  children: [
                    for (final dias in _opcoesDias)
                      Container(
                        margin: const EdgeInsets.only(bottom: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8FB),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: RadioListTile<int>(
                          value: dias,
                          title: Text('$dias dias por semana'),
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            _Secao(
              icone: Icons.water_drop_outlined,
              titulo: 'Notificações de água',
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FB),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: SwitchListTile(
                  value: _lembreteAgua,
                  onChanged: (ligado) => setState(() => _lembreteAgua = ligado),
                  title: const Text(
                    'Receber notificações para beber água',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Lembretes durante o dia'),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
            _Secao(
              icone: Icons.verified_user_outlined,
              titulo: 'Aceite dos termos',
              erro: _erroTermos,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FB),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: CheckboxListTile(
                  value: _aceitou,
                  onChanged: (marcado) =>
                      setState(() => _aceitou = marcado ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  title: const Text(
                    'Aceito os termos e condições para geração do plano de treino.',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: _checarCampos,
                icon: const Icon(Icons.bolt),
                label: const Text(
                  'Gerar Plano',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
