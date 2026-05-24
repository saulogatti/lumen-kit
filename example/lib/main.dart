import 'package:flutter/material.dart';
import 'package:neon_ui/neon_ui.dart';

void main() => runApp(const NeonExampleApp());

class NeonExampleApp extends StatelessWidget {
  const NeonExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'neon_ui example',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const _GalleryScreen(),
    );
  }
}

class _GalleryScreen extends StatefulWidget {
  const _GalleryScreen();

  @override
  State<_GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<_GalleryScreen> {
  double _progress = 0.35;
  bool _busy = false;
  String _slug = 'meu-app-neon';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NeonAppBar(
        title: 'neon_ui',
        subtitle: 'gallery',
      ),
      floatingActionButton: NeonFab.extended(
        icon: Icons.bolt_rounded,
        label: 'AÇÃO',
        onPressed: () => showNeonToast(
          context: context,
          message: 'FAB tocado!',
          tone: StatusTone.success,
          position: NeonToastPosition.top,
        ),
      ),
      body: AnimatedGridBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          children: <Widget>[
            _section(
              'Cards & status',
              NeonCard(
                glow: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const <Widget>[
                    Text('Serviço de telemetria',
                        style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text(
                      'Streaming de eventos em tempo real, 124 conexões ativas.',
                    ),
                    SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        StatusChip(label: 'OK', tone: StatusTone.success),
                        StatusChip(label: 'INFO', tone: StatusTone.info),
                        StatusChip(label: 'ALERTA', tone: StatusTone.warning),
                        StatusChip(label: 'FALHA', tone: StatusTone.danger),
                        StatusChip(label: 'OFFLINE', tone: StatusTone.neutral),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _section(
              'Botões',
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  NeonButton(
                    label: 'EXECUTAR',
                    icon: Icons.play_arrow_rounded,
                    busy: _busy,
                    onPressed: () async {
                      setState(() => _busy = true);
                      await Future<void>.delayed(const Duration(seconds: 1));
                      if (!context.mounted) return;
                      setState(() => _busy = false);
                      showNeonSnackBar(
                        context: context,
                        message: 'Pipeline executado com sucesso',
                        tone: StatusTone.success,
                      );
                    },
                  ),
                  NeonButton.outline(
                    label: 'EDITAR',
                    icon: Icons.edit,
                    onPressed: () {},
                  ),
                  NeonButton.ghost(
                    label: 'cancelar',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            _section(
              'Icon buttons & FAB',
              Row(
                children: <Widget>[
                  NeonIconButton(
                    icon: Icons.favorite,
                    tooltip: 'Curtir',
                    onPressed: () {},
                  ),
                  const SizedBox(width: 12),
                  NeonIconButton.solid(
                    icon: Icons.refresh,
                    tooltip: 'Atualizar',
                    onPressed: () {},
                  ),
                  const SizedBox(width: 12),
                  NeonIconButton.ghost(
                    icon: Icons.more_vert,
                    tooltip: 'Mais',
                    onPressed: () {},
                  ),
                  const SizedBox(width: 12),
                  NeonIconButton(
                    icon: Icons.lock_outline_rounded,
                    shape: NeonIconButtonShape.rounded,
                    onPressed: null,
                  ),
                  const Spacer(),
                  NeonTooltip(
                    message: 'Quadrado, com tooltip neon',
                    child: NeonIconButton(
                      icon: Icons.info_outline,
                      shape: NeonIconButtonShape.rounded,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
            _section(
              'Inputs',
              NeonTextField(
                label: 'Slug do projeto',
                initialValue: _slug,
                icon: Icons.tag_rounded,
                onChanged: (String v) => _slug = v,
              ),
            ),
            _section(
              'Progresso',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Determinado (${(_progress * 100).round()}%)'),
                  const SizedBox(height: 8),
                  NeonLinearProgress(value: _progress),
                  const SizedBox(height: 12),
                  Slider(
                    value: _progress,
                    onChanged: (double v) => setState(() => _progress = v),
                  ),
                  const SizedBox(height: 12),
                  const Text('Indeterminado'),
                  const SizedBox(height: 8),
                  const NeonLinearProgress(),
                  const SizedBox(height: 20),
                  Row(
                    children: const <Widget>[
                      NeonCircularProgress(value: 0.7),
                      SizedBox(width: 20),
                      NeonCircularProgress(),
                      SizedBox(width: 20),
                      NeonCircularProgress(size: 56, strokeWidth: 5),
                    ],
                  ),
                ],
              ),
            ),
            _section(
              'Skeleton (loading state)',
              Row(
                children: const <Widget>[
                  NeonSkeleton.circle(size: 48),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        NeonSkeleton(width: 160),
                        SizedBox(height: 8),
                        NeonSkeleton(width: 220, height: 10),
                        SizedBox(height: 8),
                        NeonSkeleton(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _section(
              'Feedback (snackbar, toast, dialog)',
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  NeonButton.outline(
                    label: 'SNACKBAR',
                    icon: Icons.notifications_active_outlined,
                    onPressed: () => showNeonSnackBar(
                      context: context,
                      message: 'Snackbar com tom de alerta',
                      tone: StatusTone.warning,
                      action: SnackBarAction(
                        label: 'desfazer',
                        onPressed: () {},
                      ),
                    ),
                  ),
                  NeonButton.outline(
                    label: 'TOAST',
                    icon: Icons.bolt_outlined,
                    onPressed: () => showNeonToast(
                      context: context,
                      message: 'Toast flutuante via Overlay',
                      tone: StatusTone.info,
                    ),
                  ),
                  NeonButton.outline(
                    label: 'DIALOG',
                    icon: Icons.warning_amber_rounded,
                    onPressed: () => showNeonDialog<void>(
                      context: context,
                      title: 'Confirmar ação',
                      icon: Icons.warning_amber_rounded,
                      content: const Text(
                        'Esta operação não pode ser desfeita. Deseja prosseguir?',
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                        NeonButton(
                          label: 'CONFIRMAR',
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _section(
              'Navegação',
              Column(
                children: <Widget>[
                  NavigationCard(
                    title: 'Dashboard',
                    subtitle: 'visão geral em tempo real',
                    icon: Icons.dashboard_outlined,
                    accent: AppColors.accentCyan,
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  NavigationCard(
                    title: 'Configurações',
                    subtitle: 'tokens, paleta e integrações',
                    icon: Icons.settings_outlined,
                    accent: AppColors.accentMagenta,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, Widget child) {
    final p = NeonThemeExt.of(context).palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: p.textSecondary,
              fontSize: 12,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
