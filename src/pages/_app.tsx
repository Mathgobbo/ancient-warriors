import "@/styles/globals.css";
import "../flow/config";
import type { AppProps } from "next/app";
import { Poppins } from "@next/font/google";
import { WalletAuthProvider } from "@/provider/WalletAuthProvider";

const poppins = Poppins({ subsets: ["latin"], weight: ["400", "500", "600"], variable: "--font-poppins" });

export default function App({ Component, pageProps }: AppProps) {
  return (
    <main className={`${poppins.className}`}>
      <WalletAuthProvider>
        <Component {...pageProps} />
      </WalletAuthProvider>
    </main>
  );
}
