import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../api/user_api.dart';
import '../../model/favorites_provider.dart';
import '../../model/user.dart';
import '../../model/listing.dart';
import '../../model/store.dart';
import 'payment_page.dart';
import 'store_info_page.dart';

// This widget displays the details of a specific listing from a store.
class ListingPage extends StatefulWidget {
  final Store store;
  final Listing listing;

  const ListingPage({
    super.key,
    required this.store,
    required this.listing,
  });

  @override
  State<ListingPage> createState() => _ListingPageState();
}

class _ListingPageState extends State<ListingPage> {
  Future<void> _toggleFavourite() async {
    final provider = Provider.of<FavoritesProvider>(context, listen: false);

    User? currentUser = await UserService.getUser();
    UserAPI userAPI = UserAPI('http://127.0.0.1:5000');

    bool isCurrentlyFavorite = provider.isFavorite(widget.listing);
    if (isCurrentlyFavorite) {
      await provider.removeFavorite(
          widget.listing, currentUser!.email, widget.listing.storeId, userAPI);
    } else {
      await provider.addFavorite(
          widget.listing, currentUser!.email, widget.listing.storeId, userAPI);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FavoritesProvider>(context);
    bool isFavorite = provider.isFavorite(widget.listing);

    return Container(
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFfbfaf6),
      ),
      child: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: <Widget>[
                _buildSliverAppBar(context, isFavorite),
                _buildSliverList(context),
              ],
            ),
          ),
          _buildReserveButton(context),
        ],
      ),
    );
  }

  /// Builds the top app bar for the listing page.
  /// It provides actions for sharing and marking the listing as favorite.
  SliverAppBar _buildSliverAppBar(BuildContext context, bool isFavourite) {
    return SliverAppBar(
      backgroundColor: const Color(0xFF03605f),
      stretch: true,
      leading: CupertinoButton(
          child: const Icon(CupertinoIcons.left_chevron,
              color: CupertinoColors.white),
          onPressed: () => Navigator.pop(context)),
      actions: [
        _buildAppBarActionButton(CupertinoIcons.share, context, isFavourite),
        _buildAppBarActionButton(
            isFavourite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
            context,
            isFavourite),
      ],
      expandedHeight: MediaQuery.of(context).size.height * 0.25,
      flexibleSpace: _buildFlexibleSpaceBar(context),
    );
  }

  /// Builds the flexible space bar with a background image and store details.
  FlexibleSpaceBar _buildFlexibleSpaceBar(BuildContext context) {
    return FlexibleSpaceBar(
      background: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackgroundDecoration(),
          _buildStoreDetails(context),
        ],
      ),
    );
  }

  /// Builds the top left indicator on the image
  Widget _buildLeftTopIndicator() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xfffefdc3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${widget.listing.quantityAvailable} διαθέσιμα',
        style: const TextStyle(
            color: Color(0xFF03605f),
            fontWeight: FontWeight.bold,
            fontSize: 12),
      ),
    );
  }

  DecoratedBox _buildBackgroundDecoration() {
    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(widget.store.imageBackgroundUrl),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) => const Text('Error'),
          colorFilter: const ColorFilter.linearToSrgbGamma(),
        ),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black],
        ),
      ),
    );
  }

  Positioned _buildStoreDetails(BuildContext context) {
    return Positioned(
      bottom: 10,
      left: 10,
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 20, // Provide some padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLeftTopIndicator(),
            const SizedBox(
                height:
                    10), // Increase space between indicator and store name (and make it constant
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFfbfaf6),
                    border:
                        Border.all(color: const Color(0xFFfbfaf6), width: 0.5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: CircleAvatar(
                    minRadius: 10,
                    maxRadius: 30,
                    backgroundImage: NetworkImage(widget.store.imageProfileUrl),
                  ),
                ),
                const SizedBox(width: 15), // Slightly increase space
                Flexible(
                  child: Text(
                    widget.store.name,
                    overflow: TextOverflow
                        .clip, // Ensure long text doesn't break your design
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22, // Increase font size
                      fontWeight: FontWeight.bold, // Make it bold
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Padding _buildListItem(
      IconData icon, String leftText, String rightText, String type,
      {Widget? customWidget}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
      child: Row(
        children: [
          Icon(icon, color: CupertinoColors.black, size: 16),
          const SizedBox(width: 8),
          Text(
            leftText,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
          if (customWidget != null) customWidget else const Spacer(),
          Text(
            rightText,
            style: rightText ==
                    "${(widget.listing.firstPrice).toStringAsFixed(2)} €" // Check if it's the old price
                ? const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                  )
                : const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF03605f),
                  ),
          ),
        ],
      ),
    );
  }

  /// Builds an action button for the app bar.
  /// [icon] defines the visual representation of the action.
  CupertinoButton _buildAppBarActionButton(
      IconData icon, BuildContext context, bool isFavorite) {
    return CupertinoButton(
      child: Center(
          child: Icon(icon,
              color: isFavorite && icon == CupertinoIcons.heart_fill
                  ? CupertinoColors.systemRed
                  : CupertinoColors.white,
              size: 20)),
      onPressed: () {
        // Implement the action here.
        if (icon == CupertinoIcons.share) {
          // Share the listing
          final String shareText =
              "Τσέκαρε αυτό το τέλειο γεύμα από το EcoEats: ${widget.listing.category} από ${widget.store.name}. Μόνο ${widget.listing.discountedPrice} €!";
          Share.share(shareText);
        } else if (icon == CupertinoIcons.heart ||
            icon == CupertinoIcons.heart_fill) {
          // Mark the listing as favorite
          _toggleFavourite();
        }
      },
    );
  }

  /// Formats the display date
  Widget _formatDateForDisplay(DateTime startDateTime, DateTime endDateTime) {
    DateTime now = DateTime.now();
    String dayText;
    if (startDateTime.day == now.day) {
      dayText = 'Σήμερα';
    } else if (startDateTime.day == now.add(const Duration(days: 1)).day) {
      dayText = 'Αύριο';
    } else {
      dayText =
          '${startDateTime.day}-${startDateTime.month}-${startDateTime.year}';
    }

    String timeText =
        '${startDateTime.hour.toString().padLeft(2, '0')}:${startDateTime.minute.toString().padLeft(2, '0')} - ${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(timeText, style: const TextStyle(fontSize: 16)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
          decoration: BoxDecoration(
            color: const Color(0xFF03605f), // The color of the container
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            dayText,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  SliverList _buildSliverList(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          const SizedBox(
            height: 5,
          ),
          _buildListItem(
              CupertinoIcons.bag,
              widget.listing.category,
              "${(widget.listing.firstPrice).toStringAsFixed(2)} €",
              "category"),
          _buildListItem(
              CupertinoIcons.star_fill,
              widget.store.rating.toStringAsFixed(1),
              "${(widget.listing.discountedPrice).toStringAsFixed(2)} €",
              "rating"),
          _buildListItem(
            CupertinoIcons.clock,
            "Διαθέσιμο:",
            "",
            "time",
            customWidget: _formatDateForDisplay(
                widget.listing.availabilityStartDate,
                widget.listing.availabilityEndDate),
          ),
          const Divider(thickness: 0.5),
          _buildStoreLocation(context),
          const Divider(thickness: 0.5),
          _buildListingDescription(),
          const Divider(thickness: 0.5),
          _buildIngredientsInfo(),
          const Divider(thickness: 0.5),
          _buildReviewsSection(),
          const Divider(thickness: 0.5),
          _buildInformationSection(),
          const Divider(thickness: 0.5),
        ],
      ),
    );
  }

  Widget _buildStoreLocation(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(CupertinoIcons.location_solid),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.store.address,
                  style: const TextStyle(color: Color(0xFF03605f))),
              const Text("Πληροφορίες καταστήματος",
                  style: TextStyle(
                      fontWeight: FontWeight.w300,
                      color: CupertinoColors.inactiveGray)),
            ],
          ),
          const Icon(CupertinoIcons.forward, color: Color(0xFF03605f)),
        ],
      ),
      onPressed: () {
        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext bc) {
            return StoreInfoPage(
                store: widget.store, distance: widget.listing.distance);
          },
        );
      },
    );
  }

  Padding _buildListingDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Τι περιλαμβάνει",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(widget.listing.description),
        ],
      ),
    );
  }

  Widget _buildIngredientsInfo() {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: const Row(
        children: [
          Text("Συστατικά και αλλεργιογόνα",
              style: TextStyle(color: Color(0xFF03605f))),
          Spacer(),
          Icon(CupertinoIcons.forward, color: Color(0xFF03605f)),
        ],
      ),
      onPressed: () => _showIngredientsAllergens(context),
    );
  }

  void _showIngredientsAllergens(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Animated Icon
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Icon(CupertinoIcons
                    .bag_fill), // Replace with your actual animated icon
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  "Το γεύμα σου είναι έκπληξη!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              // Text "Ask the store"
              Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  "Για περισσότερες πληροφορίες, επικοινώνησε με το κατάστημα.",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            // Cupertino Button "Got it!"
            CupertinoDialogAction(
              child: const Text("Οκ!"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Padding _buildReviewsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          const Text(
            "Τι λένε οι πελάτες",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.star_fill,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text("${widget.store.rating.toStringAsFixed(1)} / 5.0",
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Padding _buildInformationSection() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Τι πρέπει να ξέρεις",
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text("Το μαγαζί θα σου παρέχει συσκευασία για το γεύμα σου."),
        ],
      ),
    );
  }

  Widget _buildReserveButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0, top: 8.0),
      child: CupertinoButton(
        borderRadius: BorderRadius.circular(30),
        color: const Color(0xFF03605f),
        child: Text(
          "Κράτηση με ${(widget.listing.discountedPrice).toStringAsFixed(2)} €",
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          showCupertinoModalPopup(
              context: context,
              builder: (BuildContext bc) {
                return PaymentPage(
                    store: widget.store, listing: widget.listing);
              });
        },
      ),
    );
  }
}
