// app/farm/page.tsx
import { Barn } from "@/components/farm/barn";
import { FarmField } from "@/components/farm/farm-field";
import { CookingStation } from "@/components/cooking/cooking-station";

/**
 * 農場ページ
 * @returns JSX.Element
 */
export default function FarmPage() {
  return (
    <div className="grid grid-cols-1 lg:grid-cols-3 gap-4 p-4">
      <div className="lg:col-span-2 space-y-4">
        <FarmField />
        <CookingStation />
      </div>
      <div className="space-y-4">
        <Barn />
      </div>
    </div>
  );
}
