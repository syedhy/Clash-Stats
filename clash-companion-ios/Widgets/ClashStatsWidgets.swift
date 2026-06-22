import WidgetKit
import SwiftUI

@main
struct ClashStatsWidgets: WidgetBundle {
    var body: some Widget {
        WarAttackWidget()
        HeroLevelsWidget()
        DonationWidget()
    }
}
