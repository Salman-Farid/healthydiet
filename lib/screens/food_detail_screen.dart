import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/food_item.dart';

class FoodDetailScreen extends StatefulWidget {
  final FoodItem foodItem;

  const FoodDetailScreen({Key? key, required this.foodItem}) : super(key: key);

  @override
  _FoodDetailScreenState createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1500), // Slow motion fade
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 1200), // Slow motion slide
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOutSine,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: _getCategoryColor(),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 22),
              onPressed: () => Get.back(), // Instant response
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: widget.foodItem.heroTag,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getCategoryColor().withOpacity(0.7),
                        _getCategoryColor(),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          widget.foodItem.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: _getCategoryColor().withOpacity(0.3),
                              child: Center(
                                child: Icon(
                                  Icons.restaurant,
                                  color: Colors.white,
                                  size: 70,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.4),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.foodItem.name,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF424242),
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _getCategoryColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  widget.foodItem.category,
                  style: TextStyle(
                    color: _getCategoryColor(),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFFFFE0B2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_fire_department,
                        color: Color(0xFFFF8A65), size: 14),
                    SizedBox(width: 4),
                    Text(
                      '${widget.foodItem.calories} cal',
                      style: TextStyle(
                        color: Color(0xFFFF6F00),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF424242),
            ),
          ),
          SizedBox(height: 6),
          Text(
            widget.foodItem.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Key Nutrients',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF424242),
            ),
          ),
          SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: widget.foodItem.nutrients.map((nutrient) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _getCategoryColor().withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _getCategoryColor().withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  nutrient,
                  style: TextStyle(
                    color: _getCategoryColor(),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 30),
          Container(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () { // Instant response
                Get.snackbar(
                  'Added Successfully!',
                  '${widget.foodItem.name} has been added to your meal plan.',
                  backgroundColor: _getCategoryColor(),
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: EdgeInsets.all(16),
                  borderRadius: 12,
                  duration: Duration(seconds: 2),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _getCategoryColor(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0.5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Add to Meal Plan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor() {
    switch (widget.foodItem.category.toLowerCase()) {
      case 'breakfast':
        return Color(0xFFFFB74D);
      case 'lunch':
        return Color(0xFF81C784);
      case 'dinner':
        return Color(0xFFBA68C8);
      case 'snack':
        return Color(0xFF64B5F6);
      default:
        return Color(0xFF90A4AE);
    }
  }
}