import { RemotionExample } from "./index";

export const chatMessagesCode = `import { useCurrentFrame, AbsoluteFill, interpolate, Sequence } from "remotion";

export const MyAnimation = () => {
  const frame = useCurrentFrame();

  // Chat messages - easily customizable
  const MESSAGES = [
    { text: "Hey! How's it going?", isUser: false },
    { text: "Pretty good! Working on some animations", isUser: true },
    { text: "Nice! Remotion is amazing for that", isUser: false },
    { text: "Totally agree! So easy to use", isUser: true },
  ];

  // Animation timing
  const MESSAGE_DELAY = 45; // frames between messages
  const FADE_DURATION = 15;

  // Visual styling
  const COLOR_USER_BUBBLE = "#0084ff";
  const COLOR_OTHER_BUBBLE = "#e4e6eb";
  const COLOR_USER_TEXT = "#ffffff";
  const COLOR_OTHER_TEXT = "#050505";
  const COLOR_BACKGROUND = "#ffffff";

  return (
    <AbsoluteFill
      style={{
        backgroundColor: COLOR_BACKGROUND,
        padding: 40,
        justifyContent: "flex-end",
      }}
    >
      <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
        {MESSAGES.map((message, index) => {
          const messageStart = index * MESSAGE_DELAY;
          const opacity = interpolate(
            frame,
            [messageStart, messageStart + FADE_DURATION],
            [0, 1],
            { extrapolateLeft: "clamp", extrapolateRight: "clamp" }
          );
          const translateY = interpolate(
            frame,
            [messageStart, messageStart + FADE_DURATION],
            [20, 0],
            { extrapolateLeft: "clamp", extrapolateRight: "clamp" }
          );

          return (
            <div
              key={index}
              style={{
                display: "flex",
                justifyContent: message.isUser ? "flex-end" : "flex-start",
                opacity,
                transform: \`translateY(\${translateY}px)\`,
              }}
            >
              <div
                style={{
                  backgroundColor: message.isUser ? COLOR_USER_BUBBLE : COLOR_OTHER_BUBBLE,
                  color: message.isUser ? COLOR_USER_TEXT : COLOR_OTHER_TEXT,
                  padding: "12px 18px",
                  borderRadius: 20,
                  maxWidth: "70%",
                  fontSize: 18,
                  fontFamily: "system-ui, sans-serif",
                }}
              >
                {message.text}
              </div>
            </div>
          );
        })}
      </div>
    </AbsoluteFill>
  );
};`;

export const chatMessagesExample: RemotionExample = {
  id: "chat-messages",
  name: "Chat Messages",
  description: "Animated chat conversation with message bubbles",
  category: "Text",
  durationInFrames: 240,
  fps: 30,
  code: chatMessagesCode,
};
