import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FBF4),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 120, left: 24, right: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 32),
                        _buildHero(),
                        const SizedBox(height: 32),
                        _buildStatsGrid(),
                        const SizedBox(height: 32),
                        _buildAttendanceChart(),
                        const SizedBox(height: 32),
                        _buildQuickActions(),
                        const SizedBox(height: 32),
                        _buildRecentActivity(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // FAB
            Positioned(
              bottom: 40,
              right: 24,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF006F1D),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF28352E).withValues(alpha: 0.2),
                      offset: const Offset(0, 12),
                      blurRadius: 32,
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: const Color(0xFFD6E6DB),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage('https://i.pravatar.cc/150?img=47'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Tableau de Bord',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF006F1D),
                ),
              ),
            ],
          ),
          const Icon(
            Icons.notifications_none_outlined,
            color: Color(0xFF006F1D),
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Bonjour, Directrice',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Color(0xFF28352E),
            letterSpacing: -0.75,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Voici l\'aperçu de votre établissement pour aujourd\'hui.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF546259),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 159 / 185, // rough estimate from Figma dimensions
      children: [
        _buildStatCard('Total Élèves', '120', const Color(0xFF91F78E), Icons.face, const Color(0xFF28352E)),
        _buildStatCard('Enseignants', '15', const Color(0xFFA3F69C), Icons.group, const Color(0xFF28352E)),
        _buildStatCard('Classes', '8', const Color(0xFFB4FDB4), Icons.school, const Color(0xFF28352E)),
        _buildStatCard(
          'Absents', 
          '4', 
          const Color(0xFFFD795A).withValues(alpha: 0.2), 
          Icons.calendar_month, 
          const Color(0xFFA73B21),
          iconColor: const Color(0xFFA73B21),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color iconBgColor, IconData icon, Color valueColor, {Color? iconColor}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor ?? const Color(0xFF065F18), size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF546259),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceChart() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFECF6ED),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Fréquentation\nde la Semaine',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF28352E),
                  height: 1.4,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD6E6DB),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF006F1D),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '+2% vs\nsemaine\ndernière',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF006F1D),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 160,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildChartBar('LUN', 0.85),
                _buildChartBar('MAR', 0.92),
                _buildChartBar('MER', 0.78),
                _buildChartBar('JEU', 0.88),
                _buildChartBar('VEN', 0.95),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(String day, double fillRatio) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: 45,
          height: 128,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF006F1D).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              FractionallySizedBox(
                heightFactor: fillRatio,
                widthFactor: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF006F1D),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          day,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF546259),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions Rapides',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF28352E),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionBtn(
                'Signaler Absence', 
                Icons.notifications_active_outlined, 
                const Color(0xFFA73B21).withValues(alpha: 0.1),
                const Color(0xFFA73B21),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionBtn(
                'Ajouter Élève', 
                Icons.person_add_outlined, 
                const Color(0xFF1C6D25).withValues(alpha: 0.1),
                const Color(0xFF1C6D25),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionBtn(
                'Nouvelle Classe', 
                Icons.meeting_room_outlined, 
                const Color(0xFF1C6D25).withValues(alpha: 0.1),
                const Color(0xFF1C6D25),
              ),
            ),
            const SizedBox(width: 16),
            const Spacer(),
          ],
        )
      ],
    );
  }

  Widget _buildActionBtn(String title, IconData icon, Color iconBgColor, Color iconColor) {
    return Container(
      height: 130,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFA6B6AB).withValues(alpha: 0.15)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF28352E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 1),
            blurRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activité Récente',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF28352E),
            ),
          ),
          const SizedBox(height: 32),
          
          Stack(
            children: [
              Positioned(
                left: 7,
                top: 8,
                bottom: 20,
                child: Container(width: 2, color: const Color(0xFFA6B6AB).withValues(alpha: 0.3)),
              ),
              Column(
                children: [
                  _buildTimelineItem(
                    title: 'Nouvel élève inscrit',
                    time: 'Il y a 2 heures',
                    tag: 'Classe B',
                    tagColor: const Color(0xFF91F78E),
                    tagTextColor: const Color(0xFF005E17),
                  ),
                  _buildTimelineItem(
                    title: 'Absence justifiée - Léo\nThompson',
                    time: 'Il y a 4 heures',
                    tag: 'Motif médical',
                    tagColor: const Color(0xFFD6E6DB),
                    tagTextColor: const Color(0xFF546259),
                    dotColor: const Color(0xFFB4FDB4),
                  ),
                  _buildTimelineItem(
                    title: 'Nouvelle note ajoutée - Classe A',
                    time: 'Hier, 16:45',
                    tag: 'Français',
                    tagColor: const Color(0xFFA3F69C),
                    tagTextColor: const Color(0xFF065F18),
                  ),
                  _buildTimelineItem(
                    title: 'Réunion pédagogique\nterminée',
                    time: 'Hier, 14:00',
                    dotColor: const Color(0xFFA6B6AB),
                    isLast: true,
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: const Color(0xFFA6B6AB).withValues(alpha: 0.3)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(48),
                ),
              ),
              child: const Text(
                'Voir tout l\'historique',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF006F1D),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String time,
    String? tag,
    Color? tagColor,
    Color? tagTextColor,
    Color dotColor = const Color(0xFF91F78E),
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF28352E),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Color(0xFF546259),
                  ),
                ),
                if (tag != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: tagColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: tagTextColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
