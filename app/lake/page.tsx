// app/lake/page.tsx
import { LakePage as LakePageComponent } from "@/components/pages/lake-page";

/**
 * 湖ページ
 * @returns JSX.Element
 */
export default function LakePage() {
  return (
    <div className="p-4">
      <LakePageComponent />
    </div>
  );
}
