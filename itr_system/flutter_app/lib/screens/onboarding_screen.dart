import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'itr_form_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool? _knowsITR;
  bool _showVideoPage = false;

  void _handleChoice(bool knows) {
    setState(() {
      _knowsITR = knows;
      if (!knows) {
        _showVideoPage = true;
      }
    });

    if (knows) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const ITRFormScreen()));
    }
  }

  Future<void> _launchVideo() async {
    final uri = Uri.parse('https://www.youtube.com/watch?v=MjXMhbGITAQ');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showVideoPage) {
      return _buildVideoPage();
    }
    return _buildKnowledgeCheck();
  }

  Widget _buildKnowledgeCheck() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo / icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.agriculture,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Sistema ITR',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B1B1B),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Imposto sobre a Propriedade Territorial Rural',
                  style: TextStyle(fontSize: 15, color: Color(0xFF5C5C5C)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Question card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.help_outline,
                        size: 36,
                        color: Color(0xFF558B2F),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Antes de começar...',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1B1B1B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Você já tem conhecimento de como funciona a declaração do ITR e o cálculo do VTN (Valor da Terra Nua)?',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF3D3D3D),
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _handleChoice(false),
                              icon: const Icon(Icons.close, size: 18),
                              label: const Text('Não, quero aprender'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                foregroundColor: const Color(0xFF555555),
                                side: const BorderSide(
                                  color: Color(0xFFCCCCCC),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _handleChoice(true),
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text('Sim, pode continuar'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const Text(
                  'Desenvolvido para agricultores familiares de Campinorte/GO',
                  style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPage() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2E7D32)),
          onPressed: () => setState(() => _showVideoPage = false),
        ),
        title: const Text(
          'Aprenda sobre ITR',
          style: TextStyle(
            color: Color(0xFF1B1B1B),
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE8E8E8)),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                // Info card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFA5D6A7)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF2E7D32),
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Não se preocupe! O ITR pode parecer complicado, mas com o material certo fica fácil de entender. Assista ao vídeo abaixo antes de prosseguir.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1B5E20),
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Video card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F7F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.red.shade600,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Como declarar o ITR — Guia completo',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3D3D3D),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Receita Federal do Brasil',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF888888),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _launchVideo,
                          icon: const Icon(Icons.play_circle_outline, size: 20),
                          label: const Text('Assistir vídeo explicativo'),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Topics covered
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'O que você vai aprender:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3D3D3D),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...[
                        'O que é o ITR e quem deve declarar',
                        'Como calcular o Valor da Terra Nua (VTN)',
                        'Prazos e penalidades por atraso',
                        'Isenções para pequenos produtores rurais',
                      ].map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                size: 16,
                                color: Color(0xFF2E7D32),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF3D3D3D),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ITRFormScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text('Já assisti, quero continuar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: const Color(0xFF2E7D32),
                      side: const BorderSide(color: Color(0xFF2E7D32)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
