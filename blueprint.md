# AgriChain Application Blueprint

## Overview

AgriChain is a blockchain-based supply chain tracking application for agricultural products. It provides transparency and traceability from the farm to the consumer, ensuring the authenticity and quality of the products.

## Style, Design, and Features

### Authentication & Roles

- **Role-based access control:** The app supports four distinct user roles: Farmer, Distributor, Retailer, and Consumer.
- **Firebase Authentication:** User registration and login are handled securely via Firebase email/password authentication.
- **Auth Wrapper:** A central `AuthWrapper` manages user sessions and directs users to the appropriate home screen based on their assigned role, which is stored in their Firebase profile.

### Core Application Flow

1.  **Welcome & Onboarding:** A visually appealing welcome screen greets new users and provides clear options for logging in or registering a new account.
2.  **Role-Specific Dashboards:** Each user role has a dedicated home screen tailored to their specific tasks:
    *   **Farmer:** Can create new crop batches and view their existing inventory.
    *   **Distributor:** Can scan batches from farmers and transfer them to retailers.
    *   **Retailer:** Can receive batches from distributors and make them available to consumers.
    *   **Consumer:** Can scan product QR codes to view their complete journey.
3.  **Batch Creation:** Farmers can create new batches by providing details like crop name, farm name, planting date, and harvest date. The app automatically captures the farmer's current GPS location to ensure accurate origin data.
4.  **QR Code Generation:** Upon creating a batch, a unique QR code is generated and displayed, containing the batch ID. This QR code serves as the physical link to the digital record on the blockchain.
5.  **Batch Transfer:** Distributors and retailers can scan a batch's QR code to initiate a transfer of ownership. The process is streamlined into three steps: scanning, confirming details, and executing the transfer on the backend.
6.  **Product History:** Consumers can scan the final product's QR code to view its complete, end-to-end journey. The history is presented in a user-friendly, vertical timeline, detailing each step from the farm to the store shelf.

### UI/UX & Design Language

- **Consistent Theming:** The application uses a unified, modern theme with a green color palette inspired by agriculture. A consistent `ThemeData` object ensures that all screens, buttons, and components share a cohesive look and feel.
- **Intuitive Layouts:** Screens are designed with a clean, organized, and mobile-responsive layout. Logical sections, clear headings, and ample spacing enhance readability and ease of use.
- **Interactive Components:** The app utilizes a range of modern UI components, including:
    *   **Cards:** For displaying batch information, QR codes, and timeline events.
    *   **Icons:** To improve visual communication and user guidance.
    *   **Elevated Buttons & Text Fields:** Styled for a modern aesthetic and clear calls to action.
- **User Feedback:** The app provides continuous feedback through:
    *   **Loading Indicators:** During asynchronous operations like API calls.
    *   **Snackbars:** For displaying success messages (e.g., "Batch transferred successfully") and error alerts.
    *   **Animated Transitions:** Smooth animations between different UI states (e.g., scanning to confirming) provide a seamless user experience.

### Technical Implementation

- **Flutter Framework:** The application is built using Flutter, allowing for a cross-platform codebase for both mobile and web.
- **GoRouter:** For declarative and robust navigation, handling deep linking and authentication-based redirects.
- **Firebase Integration:** Leverages Firebase for authentication and potentially other backend services in the future.
- **API Client:** A dedicated `ApiClient` class abstracts all communication with the backend blockchain service, making the code cleaner and easier to maintain.
- **QR Code Scanning & Generation:** Utilizes the `mobile_scanner` and `qr_flutter` packages for a seamless QR code experience.
- **Location Services:** The `location` package is used to fetch the device's GPS coordinates for accurate data logging.

## Current Plan

- **COMPLETE:** Refine the UI for all existing screens to ensure a consistent and modern user experience.
- **COMPLETE:** Create a new `ConsumerBatchHistoryScreen` to display the product's journey in a user-friendly timeline.
- **COMPLETE:** Integrate the new history screen into the application's navigation flow.
- **COMPLETE:** Polish the home screens for each user role (Farmer, Distributor, Retailer, Consumer) with improved layouts and user-centric design.
- **COMPLETE:** Enhance the `CreateBatchScreen` with a more intuitive form design and better user feedback.
- **COMPLETE:** Improve the `QrDisplayScreen` and `TransferBatchScreen` for a more streamlined and visually appealing workflow.

