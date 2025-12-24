// app/forest/page.tsx
import { HuntingArea } from "@/components/hunting/hunting-area";

/**
 * 森ページ（狩り）
 * @returns JSX.Element
 */
export default function ForestPage() {
  return (
    <div className="p-4">
      <HuntingArea />
    </div>
  );
}
