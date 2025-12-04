# PATTERNS

- Slack GIFs have strict size constraints: 128x128 for emoji, 480x480 for messages.
- Lower FPS (10-30) and fewer colors (48-128) directly reduce file size significantly.
- Duration under 3 seconds is critical for emoji GIFs to work properly.
- PIL ImageDraw primitives are the core drawing method, not pre-packaged graphics.
- Thicker lines (width=2+) make graphics look polished versus amateurish thin lines.
- Easing functions create smooth, professional motion instead of linear robotic movement.
- Combining multiple animation concepts creates more engaging, creative GIF results.
- Visual depth through gradients and layered shapes elevates basic graphics significantly.
- Remove duplicate frames to optimize file size without sacrificing animation quality.
- User-uploaded images serve dual purposes: direct use or inspiration for creation.
- Emoji fonts are unreliable across platforms and should be avoided completely.
- Vibrant, complementary colors with contrast create better visual impact than plain colors.
- Particle systems require tracking velocity, position, gravity, and alpha per particle.
- Rotation uses PIL's rotate method with BICUBIC resampling for quality.
- RGBA alpha channel manipulation enables fade in/out effects smoothly.
- Optimization should only happen when explicitly requested, not by default.
- Stars, hearts, snowflakes need careful polygon point calculation for proper symmetry.
- Bounce animations combine ease_in for falling with bounce_out for landing.
- Mathematical functions (sin, cos) drive oscillation effects like shake and pulse.
- The toolkit provides knowledge and utilities, not rigid templates or pre-made functions.
- GIFBuilder centralizes frame assembly and Slack-specific optimization in one interface.
- Validators check Slack requirements before upload to prevent rejection issues.
- Slide animations use interpolation with ease_out for natural deceleration at destination.
- Zoom effects combine scaling with cropping to maintain frame dimensions.
- Multiple shapes layered together create complexity that single shapes cannot achieve.
- Highlights and rings on basic shapes add dimension and professional polish.
- Sine wave frequency adjustments create heartbeat patterns with pause timing.
- Back_out easing creates overshoot effect for playful, energetic animation feel.
- Elastic_out easing produces springy, bouncy motion for comedic or exaggerated effects.
- Frame composer helpers accelerate common tasks like gradients and basic shapes.

# META

- Size constraints (128x128, 480x480) mentioned in Slack Requirements and referenced throughout workflow.
- FPS and color reduction for file size appears in Requirements, Optimization, and workflow.
- 3-second duration limit specifically mentioned once in Requirements for emoji GIFs.
- PIL ImageDraw primitives emphasized in Drawing Graphics, Philosophy, and multiple code examples.
- Thick lines (width=2+) highlighted specifically in Making Graphics Look Good section.
- Easing functions detailed in dedicated utility section and referenced in animation concepts.
- Combining concepts encouraged in Philosophy and implied across multiple animation concept descriptions.
- Visual depth through gradients/layers stressed in Making Graphics Look Good section explicitly.
- Remove duplicates mentioned in Optimization Strategies and GIFBuilder save method parameters.
- User-uploaded images discussed in Working with User-Uploaded Images with dual interpretation.
- Emoji font warning appears in Drawing from Scratch and Philosophy sections.
- Color advice (vibrant, complementary, contrast) concentrated in Making Graphics Look Good section.
- Particle systems detailed in Explode/Particle Burst animation concept with velocity/gravity tracking.
- Rotation method specified in Spin/Rotate concept with PIL rotate and BICUBIC parameter.
- RGBA alpha manipulation explained in Fade In/Out concept with blend method.
- Optimization timing ("only when asked") explicitly stated in Optimization Strategies introduction.
- Symmetry calculation for complex shapes mentioned in Making Graphics Look Good details.
- Bounce combining ease_in and bounce_out described in Bounce animation concept specifically.
- Sin/cos for oscillation mentioned in Shake/Vibrate and Pulse/Heartbeat animation concepts.
- Philosophy section explicitly states what toolkit provides versus doesn't provide three times.
- GIFBuilder interface described in Available Utilities and Core Workflow with consistent API.
- Validators utility explained in dedicated section with both detailed and quick-check methods.
- Slide with ease_out mentioned in Slide animation concept for smooth stopping.
- Zoom scaling range (0.1 to 2.0) specified in Zoom animation concept explicitly.
- Layering shapes for complexity recommended in Making Graphics Look Good section.
- Highlights/rings on shapes suggested in Making Graphics Look Good as enhancement technique.
- Heartbeat timing pattern described in Pulse/Heartbeat with two-pulse-pause rhythm.
- Back_out overshoot effect mentioned in Slide concept and easing function list.
- Elastic_out springy motion listed in easing functions as available option.
- Frame composer helpers listed in dedicated utility section with specific function names.

# ANALYSIS

Slack GIF creation demands strict technical constraints (size, colors, FPS) while emphasizing creative polish through layered shapes, thick lines, easing functions, and combined animation concepts, with PIL primitives as the foundational drawing method.

# BEST 5

- **Slack GIFs have strict size constraints: 128x128 for emoji, 480x480 for messages.** This is the foundational requirement mentioned first in documentation and referenced throughout workflow examples, making it the primary constraint builders must respect.

- **Lower FPS (10-30) and fewer colors (48-128) directly reduce file size significantly.** This pattern appears in Requirements, Optimization Strategies, and workflow examples as the most effective file size control method, critical for Slack's upload limits.

- **Thicker lines (width=2+) make graphics look polished versus amateurish thin lines.** Explicitly called out in Making Graphics Look Good as distinguishing professional from amateur work, with specific implementation guidance across all drawing examples.

- **Easing functions create smooth, professional motion instead of linear robotic movement.** Dedicated utility section plus references across six animation concepts demonstrates this as essential for quality, with seven specific easing types provided for different effects.

- **Combining multiple animation concepts creates more engaging, creative GIF results.** Philosophy section explicitly encourages this approach, with examples like "bouncing + rotating, pulsing + sliding" showing how basic concepts combine for sophisticated animations.

# ADVICE FOR BUILDERS

- Start with 128x128 emoji size; it's easier to optimize than downsizing later.
- Default to 10 FPS and 48 colors; only increase if animation needs it.
- Always use width=2 or higher for lines; thin lines signal amateur work.
- Implement easing functions from day one; linear motion looks robotic and cheap.
- Layer multiple shapes instead of single primitives for professional visual depth.
- Build a library of reusable animation combinations, not just single effects.
- Validate GIFs before user upload to catch Slack requirement failures early.
- Provide optimization as optional feature, not automatic; preserve user creative intent.
- Use PIL primitives exclusively; avoid emoji fonts or platform-dependent rendering methods.
- Add gradient backgrounds by default; solid colors look flat and unfinished.
- Design for vibrant contrast; Slack's interface is light, GIFs need pop.
- Calculate complex shape points programmatically for consistency and parameterization at scale.
- Track animation state per object for particle systems and multi-element animations.
- Offer pre-built easing + animation concept combinations as starting templates for users.
- Document file size impact of each parameter change for transparent user control.