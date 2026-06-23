import SwiftUI

struct AutoRetryImage: View {
    let url: URL?
    var maxRetries: Int = 3
    
    @State private var retryCount = 0
    
    var body: some View {
        AsyncImage(url: url) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .scaledToFit()
            } else if phase.error != nil {
                Image(systemName: "photo")
                    .foregroundColor(.secondary)
                    .onAppear {
                        if retryCount < maxRetries {
                            // Automatically retry after 2 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                retryCount += 1
                            }
                        }
                    }
            } else {
                ProgressView()
            }
        }
        .id(retryCount) // Modifying the ID forces AsyncImage to completely restart its fetch
    }
}
